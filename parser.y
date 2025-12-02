%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "codegen.h"

extern FILE *yyin;
extern int yylineno;
int yylex();
void yyerror(const char *s);
ASTNode* root = NULL;
%}

%union {
    char* sval;
    struct ASTNode* node;
}

%token <sval> INT_LIT FLOAT_LIT STRING_LIT ID
%token KW_ITEM KW_CIRCUIT KW_DROP
%token TYPE_REDSTONE TYPE_BOAT TYPE_BOOL TYPE_TEXT TYPE_VOID TYPE_INVENTORY
%token KW_COMPARATOR KW_OBSERVER KW_HOPPER KW_REPEATER KW_PISTON
%token KW_CHAT KW_GLOWSTONE KW_PRESSURE KW_LEVER
%token KW_NEW_INV KW_STORE KW_SIZE
%token ASSIGN PLUS MINUS MULT DIV MOD POW
%token EQ NEQ LT GT LTE GTE
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COMMA

%type <node> program statement_list statement block var_decl assignment assignment_nosemi print_stmt pixel_stmt if_stmt while_stmt for_stmt expression term factor input_expr
%type <sval> type

%left EQ NEQ
%left LT GT LTE GTE
%left PLUS MINUS
%left MULT DIV MOD
%right POW

%%

program:
    statement_list { root = $1; }
    ;

statement_list:
    statement { 
        $$ = new_node(NODE_BLOCK, $1, NULL); 
    }
    | statement_list statement {
        ASTNode* ptr = $1;
        while(ptr->next != NULL) ptr = ptr->next;
        ptr->next = new_node(NODE_BLOCK, $2, NULL);
        $$ = $1;
    }
    ;

statement:
    var_decl
    | assignment
    | print_stmt
    | pixel_stmt
    | if_stmt
    | while_stmt
    | for_stmt
    | block { $$ = $1; }
    ;

block:
    LBRACE statement_list RBRACE { $$ = $2; }
    ;

var_decl:
    KW_ITEM type ID ASSIGN expression SEMICOLON {
        $$ = new_decl($2, $3, $5);
    }
    | KW_ITEM type ID ASSIGN input_expr SEMICOLON {
        $$ = new_decl($2, $3, $5);
    }
    ;

assignment:
    ID ASSIGN expression SEMICOLON {
        $$ = new_node(NODE_ASSIGN, new_var_ref($1), $3);
    }
    ;

assignment_nosemi:
    ID ASSIGN expression {
        $$ = new_node(NODE_ASSIGN, new_var_ref($1), $3);
    }
    ;

print_stmt:
    KW_CHAT LPAREN expression RPAREN SEMICOLON {
        $$ = new_node(NODE_PRINT, $3, NULL);
    }
    ;

pixel_stmt:
    KW_GLOWSTONE LPAREN expression COMMA expression COMMA expression RPAREN SEMICOLON {
        $$ = new_pixel($3, $5, $7);
    }
    ;

input_expr:
     KW_LEVER LPAREN INT_LIT RPAREN { 
         $$ = new_node(NODE_KEY, NULL, NULL); $$->value = strdup($3); 
     }
   | KW_PRESSURE LPAREN INT_LIT RPAREN { 
         $$ = new_node(NODE_KEY, NULL, NULL); $$->value = strdup($3); 
     }
   ;

if_stmt:
    KW_COMPARATOR LPAREN expression RPAREN block {
        $$ = new_flow_control(NODE_IF, $3, $5, NULL);
    }
    | KW_COMPARATOR LPAREN expression RPAREN block KW_OBSERVER block {
        $$ = new_flow_control(NODE_IF, $3, $5, $7);
    }
    ;

while_stmt:
    KW_REPEATER LPAREN expression RPAREN block {
        $$ = new_flow_control(NODE_WHILE, $3, $5, NULL);
    }
    ;

for_stmt:
    KW_PISTON LPAREN var_decl expression SEMICOLON assignment_nosemi RPAREN block {
        ASTNode* extra_info = new_node(NODE_BLOCK, $4, $6); 
        $$ = new_flow_control(NODE_FOR, $3, $8, extra_info);
    }
    ;

expression:
    expression PLUS expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("+"); }
    | expression MINUS expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("-"); }
    | expression EQ expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("=="); }
    | expression NEQ expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("!="); }
    | expression LT expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("<"); }
    | expression GT expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup(">"); }
    | expression LTE expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("<="); }
    | expression GTE expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup(">="); }
    | expression MULT expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("*"); }
    | expression DIV expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("/"); }
    | expression MOD expression { $$=new_node(NODE_BIN_OP, $1, $3); $$->value=strdup("%"); }
    | term
    ;

term: factor ;

factor:
    LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = new_var_ref($1); }
    | INT_LIT { $$ = new_literal($1); }
    | FLOAT_LIT { $$ = new_literal($1); }
    | STRING_LIT { $$ = new_literal($1); }
    ;

type:
      TYPE_REDSTONE { $$ = "int"; }
    | TYPE_BOAT     { $$ = "float"; }
    | TYPE_TEXT     { $$ = "string"; }
    | TYPE_BOOL     { $$ = "bool"; }
    | TYPE_VOID     { $$ = "void"; }
    | TYPE_INVENTORY { $$ = "inventory"; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s en linea %d\n", s, yylineno);
    exit(1);
}