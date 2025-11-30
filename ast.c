#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Crea un nodo genérico del AST.*/
ASTNode* new_node(NodeType type, ASTNode* left, ASTNode* right) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->type = type;
    node->value = NULL;
    node->left = left;
    node->right = right;
    node->extra = NULL;
    node->next = NULL;
    return node;
}

/* Crea un nodo literal  */
ASTNode* new_literal(char* val) {
    ASTNode* node = new_node(NODE_LITERAL, NULL, NULL);
    node->value = strdup(val);
    return node;
}

/* Crea un nodo que referencia una variable */
ASTNode* new_var_ref(char* name) {
    ASTNode* node = new_node(NODE_VAR_REF, NULL, NULL);
    node->value = strdup(name);
    return node;
}

/* Crea una declaración de variable */
ASTNode* new_decl(char* type, char* name, ASTNode* init) {
    ASTNode* node = new_node(NODE_VAR_DECL, init, NULL);
    node->data_type = strdup(type);
    node->value = strdup(name);
    return node;
}

/* Crea estructuras de control: IF, WHILE y FOR */
ASTNode* new_flow_control(NodeType type, ASTNode* cond, ASTNode* body, ASTNode* extra) {
    ASTNode* node = new_node(type, cond, body);
    node->extra = extra;
    return node;
}

/* Instrucciones gráficas tipo Glowstone(x,y,z) */
ASTNode* new_pixel(ASTNode* x, ASTNode* y, ASTNode* color) {
    ASTNode* node = new_node(NODE_PIXEL, x, y);
    node->extra = color;
    return node;
}

/* Libera memoria de todo el árbol de forma recursiva */
void free_ast(ASTNode* node) {
    if (!node) return;
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->extra);
    free_ast(node->next);

    if (node->value) free(node->value);
    if (node->data_type) free(node->data_type);

    free(node);
}
