#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "codegen.h"

int temp_count = 0;
int label_count = 0;

char* get_new_temp(FILE* out) {
    static char buffer[20];
    sprintf(buffer, "_t%d", temp_count++);
    fprintf(out, "VAR %s\n", buffer);
    return strdup(buffer);
}

char* get_new_label() {
    static char buffer[20];
    sprintf(buffer, "L%d", label_count++);
    return strdup(buffer);
}

// Retorna el nombre de la variable donde quedo el resultado
char* emit_expression(ASTNode* node, FILE* out) {
    if (!node) return "0";
    
    if (node->type == NODE_LITERAL || node->type == NODE_VAR_REF) {
        return node->value;
    }

    if (node->type == NODE_BIN_OP) {
        char* left = emit_expression(node->left, out);
        char* right = emit_expression(node->right, out);
        char* temp = get_new_temp(out);
        
        char* op = "";
        if (strcmp(node->value, "+") == 0) op = "ADD";
        if (strcmp(node->value, "-") == 0) op = "SUB";
        if (strcmp(node->value, "*") == 0) op = "MUL";
        if (strcmp(node->value, "/") == 0) op = "DIV";
        if (strcmp(node->value, "%") == 0) op = "MOD";
        if (strcmp(node->value, "==") == 0) op = "EQ";
        if (strcmp(node->value, "!=") == 0) op = "NEQ";
        if (strcmp(node->value, "<") == 0) op = "LT";
        if (strcmp(node->value, ">") == 0) op = "GT";
        if (strcmp(node->value, "<=") == 0) op = "LTE";
        if (strcmp(node->value, ">=") == 0) op = "GTE";

        fprintf(out, "%s %s %s %s\n", op, left, right, temp);
        return temp;
    }
    return "0";
}

void generate_code(ASTNode* node, FILE* out) {
    if (!node) return;

    switch (node->type) {
        case NODE_BLOCK: {
            ASTNode* current = node;
            while (current) {
                generate_code(current->left, out); // Ejecutar sentencia
                current = current->next;
            }
            break;
        }

        case NODE_VAR_DECL:
            fprintf(out, "VAR %s\n", node->value);
            if (node->left) { // Init value
                if (node->left->type == NODE_KEY) {
                    fprintf(out, "KEY %s %s\n", node->left->value, node->value);
                } else {
                    char* res = emit_expression(node->left, out);
                    fprintf(out, "ASSIGN %s %s\n", res, node->value);
                }
            }
            break;

        case NODE_ASSIGN: {
            char* res = emit_expression(node->right, out);
            fprintf(out, "ASSIGN %s %s\n", res, node->left->value);
            break;
        }

        case NODE_PRINT: {
            char* res = emit_expression(node->left, out);
            fprintf(out, "PRINT %s\n", res);
            break;
        }

        case NODE_PIXEL: {
            char* x = emit_expression(node->left, out);
            char* y = emit_expression(node->right, out);
            char* c = emit_expression(node->extra, out);
            fprintf(out, "PIXEL %s %s %s\n", x, y, c);
            break;
        }

        case NODE_IF: {
            char* cond = emit_expression(node->left, out);
            char* label_else = get_new_label();
            char* label_end = get_new_label();
            
            fprintf(out, "IFFALSE %s GOTO %s\n", cond, label_else);
            generate_code(node->right, out); // Then block
            fprintf(out, "GOTO %s\n", label_end);
            
            fprintf(out, "LABEL %s\n", label_else);
            if (node->extra) generate_code(node->extra, out); // Else block
            
            fprintf(out, "LABEL %s\n", label_end);
            break;
        }

        case NODE_WHILE: {
            char* label_start = get_new_label();
            char* label_end = get_new_label();
            
            fprintf(out, "LABEL %s\n", label_start);
            char* cond = emit_expression(node->left, out);
            fprintf(out, "IFFALSE %s GOTO %s\n", cond, label_end);
            
            generate_code(node->right, out); // Body
            fprintf(out, "GOTO %s\n", label_start);
            fprintf(out, "LABEL %s\n", label_end);
            break;
        }

        case NODE_FOR: {
            char* label_start = get_new_label();
            char* label_body = get_new_label();
            char* label_inc = get_new_label();
            char* label_end = get_new_label();

            // 1. Inicializacion
            generate_code(node->left, out); 
            
            // 2. Condicion
            fprintf(out, "LABEL %s\n", label_start);
            // El nodo extra tiene {cond, update}. Left de extra es cond.
            char* cond = emit_expression(node->extra->left, out);
            fprintf(out, "IFFALSE %s GOTO %s\n", cond, label_end);
            
            fprintf(out, "GOTO %s\n", label_body);

            // 3. Incremento
            fprintf(out, "LABEL %s\n", label_inc);
            generate_code(node->extra->right, out); // Update stmt
            fprintf(out, "GOTO %s\n", label_start);

            // 4. Cuerpo
            fprintf(out, "LABEL %s\n", label_body);
            generate_code(node->right, out); // Body block
            fprintf(out, "GOTO %s\n", label_inc);

            fprintf(out, "LABEL %s\n", label_end);
            break;
        }
    }
}