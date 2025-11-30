#ifndef AST_H
#define AST_H

/* Enumeración de tipos de nodo utilizados en el Árbol de Sintaxis Abstracta. */
typedef enum {
    NODE_VAR_DECL,
    NODE_ASSIGN,
    NODE_PRINT,
    NODE_PIXEL,
    NODE_KEY,
    NODE_IF,
    NODE_WHILE,
    NODE_FOR,
    NODE_BLOCK,
    NODE_BIN_OP,
    NODE_LITERAL,
    NODE_VAR_REF
} NodeType;

/* 
 * Estructura base para todos los nodos del AST.
 * Cada nodo puede representar expresiones, sentencias o estructuras de control.
 */
typedef struct ASTNode {
    NodeType type;          // Tipo de nodo
    char *value;            // Literal o nombre de variable
    char *data_type;        // Tipo de dato asociado (en declaraciones)
    struct ASTNode *left;   // Hijo izquierdo (o primer elemento)
    struct ASTNode *right;  // Hijo derecho (o segundo elemento)
    struct ASTNode *extra;  // Nodo adicional (else en IF, update en FOR)
    struct ASTNode *next;   // Enlaces para listas de sentencias
} ASTNode;

/* Constructores de nodos AST */
ASTNode* new_node(NodeType type, ASTNode* left, ASTNode* right);
ASTNode* new_literal(char* val);
ASTNode* new_var_ref(char* name);
ASTNode* new_decl(char* type, char* name, ASTNode* init);
ASTNode* new_flow_control(NodeType type, ASTNode* cond, ASTNode* body, ASTNode* else_or_update);
ASTNode* new_pixel(ASTNode* x, ASTNode* y, ASTNode* color);

void free_ast(ASTNode* node);

#endif
