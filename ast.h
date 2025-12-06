#ifndef AST_H
#define AST_H

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
    NODE_VAR_REF,
    NODE_INPUT
} NodeType;

typedef struct ASTNode {
    NodeType type;
    char *value;            
    char *data_type;        
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *extra;  
    struct ASTNode *next;  
} ASTNode;

// Constructores
ASTNode* new_node(NodeType type, ASTNode* left, ASTNode* right);
ASTNode* new_literal(char* val);
ASTNode* new_var_ref(char* name);
ASTNode* new_decl(char* type, char* name, ASTNode* init);
ASTNode* new_flow_control(NodeType type, ASTNode* cond, ASTNode* body, ASTNode* else_or_update);
ASTNode* new_pixel(ASTNode* x, ASTNode* y, ASTNode* color);
void free_ast(ASTNode* node);

#endif