#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantic.h"

typedef struct Symbol {
    char* name;
    char* type; 
    int scope_level;
    struct Symbol* next;
} Symbol;

Symbol* symbol_table = NULL;
int current_scope = 0; 

void add_symbol(char* name, char* type) {
    Symbol* s = malloc(sizeof(Symbol));
    s->name = strdup(name);
    s->type = strdup(type);
    s->scope_level = current_scope;
    s->next = symbol_table;
    symbol_table = s;
}

Symbol* find_symbol(char* name) {
    Symbol* current = symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) return current;
        current = current->next;
    }
    return NULL;
}

Symbol* find_symbol_current_scope(char* name) {
    Symbol* current = symbol_table;
    while (current) {
        if (current->scope_level < current_scope) return NULL;
        if (current->scope_level == current_scope && strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void exit_scope() {
    while (symbol_table && symbol_table->scope_level == current_scope) {
        Symbol* temp = symbol_table;
        symbol_table = symbol_table->next;
        free(temp);
    }
    current_scope--;
}

void enter_scope() {
    current_scope++;
}



char* get_type(ASTNode* node) {
    if (!node) return "void";
    
    if (node->type == NODE_LITERAL) {
        if (strchr(node->value, '.')) return "float";
        if (node->value[0] == '"') return "string";
        return "int"; 
    }
    
    if (node->type == NODE_VAR_REF) {
        Symbol* s = find_symbol(node->value);
        if (s) return s->type;
        return "unknown";
    }
    
    if (node->type == NODE_BIN_OP) {
        char* op = node->value;
        if (strcmp(op, "==")==0 || strcmp(op, "!=")==0 || 
            strcmp(op, "<")==0 || strcmp(op, ">")==0 || 
            strcmp(op, "<=")==0 || strcmp(op, ">=")==0) {
            return "int";
        }
        return get_type(node->left);
    }

    if (node->type == NODE_KEY) return "int"; 

    return "void";
}

int error_count = 0;

void check_node(ASTNode* node) {
    if (!node) return;

    switch (node->type) {
        case NODE_VAR_DECL: {
            if (find_symbol_current_scope(node->value)) {
                printf("Error Semantico: Variable '%s' re-declarada en el mismo bloque.\n", node->value);
                error_count++;
            } else {
                add_symbol(node->value, node->data_type);
                
                if (node->left) {
                    char* valType = get_type(node->left);
                }
            }
            break;
        }

        case NODE_ASSIGN: {
            Symbol* s = find_symbol(node->left->value);
            if (!s) {
                printf("Error Semantico: Asignacion a variable no declarada '%s'.\n", node->left->value);
                error_count++;
            }
            check_node(node->right);
            break;
        }

        case NODE_VAR_REF: {
            if (!find_symbol(node->value)) {
                printf("Error Semantico: Uso de variable no declarada '%s'.\n", node->value);
                error_count++;
            }
            break;
        }

        case NODE_IF:
            check_node(node->left);
            
            enter_scope();          
            check_node(node->right);
            exit_scope();           
            
            if (node->extra) {
                enter_scope();      
                check_node(node->extra);
                exit_scope();       
            }
            break;

        case NODE_WHILE:
            check_node(node->left);
            enter_scope();
            check_node(node->right);
            exit_scope();
            break;

        case NODE_FOR:
            enter_scope(); 
            
            check_node(node->left);
            
            if (node->extra) {
                check_node(node->extra->left);  
                check_node(node->extra->right);
            }
            check_node(node->right); 
            
            exit_scope();
            break;
            
        case NODE_BLOCK:
            check_node(node->left);
            break;
            
        case NODE_PRINT:
        case NODE_PIXEL:
        case NODE_BIN_OP:
            check_node(node->left);
            check_node(node->right);
            check_node(node->extra);
            break;
            
        default:
            break;
    }

    check_node(node->next);
}

int semantic_analysis(ASTNode* root) {
    error_count = 0;
    current_scope = 0;
    symbol_table = NULL;
    check_node(root);
    return error_count;
}