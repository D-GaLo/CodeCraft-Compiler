%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
FILE *outfile;
extern int yylineno;

int yylex();
void yyerror(const char *s);

// --- GENERADORES ---
int temp_count = 0;
char* gen_temp() {
    char buffer[20];
    sprintf(buffer, "_t%d", temp_count++);
    fprintf(outfile, "VAR %s\n", buffer);
    return strdup(buffer);
}

int label_count = 0;
char* gen_label() {
    char buffer[20];
    sprintf(buffer, "L%d", label_count++);
    return strdup(buffer);
}

// --- PILAS ---
struct LoopInfo {
    char *start;
    char *end;
    char *body;
    char *inc;
} loop_stack[100];
int l_top = -1;

void push_loop(char *s, char *e, char *b, char *i) {
    l_top++;
    loop_stack[l_top].start = s;
    loop_stack[l_top].end = e;
    loop_stack[l_top].body = b;
    loop_stack[l_top].inc = i;
}
void pop_loop() { l_top--; }

struct IfInfo {
    char *label_else;
    char *label_end;
} if_stack[100];
int i_top = -1;

void push_if(char *l_else, char *l_end) {
    i_top++;
    if_stack[i_top].label_else = l_else;
    if_stack[i_top].label_end = l_end;
}
void pop_if() { i_top--; }

%}

%union {
    char* sval;
}

%token <sval> INT_LIT FLOAT_LIT STRING_LIT ID
%token KW_ITEM KW_CIRCUIT KW_DROP
%token TYPE_REDSTONE TYPE_BOAT TYPE_BOOL TYPE_TEXT TYPE_VOID TYPE_INVENTORY
%token KW_COMPARATOR KW_OBSERVER KW_HOPPER KW_REPEATER KW_PISTON
%token KW_CHAT KW_GLOWSTONE KW_PRESSURE KW_LEVER
%token KW_NEW_INV KW_STORE KW_SIZE
%token ASSIGN PLUS MINUS MULT DIV MOD POW
%token EQ NEQ LT GT LTE GTE  /* NUEVOS TOKENS AQUI */
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMICOLON COMMA

%type <sval> expression term factor type condition input_expr

%left PLUS MINUS
%left MULT DIV MOD
%right POW

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    var_decl
    | assignment
    | print_stmt
    | pixel_stmt
    | input_stmt
    | if_stmt
    | while_stmt
    | for_stmt
    | block
    ;

block:
    LBRACE statement_list RBRACE
    ;

// --- DECLARACION ---
var_decl:
    KW_ITEM type ID ASSIGN expression SEMICOLON {
        fprintf(outfile, "VAR %s\n", $3);
        fprintf(outfile, "ASSIGN %s %s\n", $5, $3);
    }
    | KW_ITEM type ID ASSIGN input_expr SEMICOLON { 
        fprintf(outfile, "VAR %s\n", $3);
        fprintf(outfile, "KEY %s %s\n", $5, $3); 
    }
    | KW_ITEM type ID ASSIGN KW_NEW_INV LPAREN RPAREN SEMICOLON { 
        fprintf(outfile, "VAR %s\n", $3);
        fprintf(outfile, "ASSIGN 0 %s\n", $3);
    }
    ;

// --- ASIGNACION ---
assignment:
    ID ASSIGN expression SEMICOLON {
        fprintf(outfile, "ASSIGN %s %s\n", $3, $1);
    }
    ;

for_update:
    ID ASSIGN expression {
        fprintf(outfile, "ASSIGN %s %s\n", $3, $1);
    }
    ;

input_stmt:
    input_expr SEMICOLON
    ;

input_expr:
     KW_LEVER LPAREN INT_LIT RPAREN { $$ = $3; }
   | KW_PRESSURE LPAREN INT_LIT RPAREN { $$ = $3; }
   ;

print_stmt:
    KW_CHAT LPAREN expression RPAREN SEMICOLON {
        fprintf(outfile, "PRINT %s\n", $3);
    }
    ;

pixel_stmt:
    KW_GLOWSTONE LPAREN expression COMMA expression COMMA expression RPAREN SEMICOLON {
        fprintf(outfile, "PIXEL %s %s %s\n", $3, $5, $7);
    }
    ;

if_stmt:
    KW_COMPARATOR LPAREN condition RPAREN {
        char *L_else = gen_label();
        char *L_end = gen_label();
        push_if(L_else, L_end);
        fprintf(outfile, "IFFALSE %s GOTO %s\n", $3, L_else);
    } block {
        fprintf(outfile, "GOTO %s\n", if_stack[i_top].label_end);
        fprintf(outfile, "LABEL %s\n", if_stack[i_top].label_else);
    } optional_else
    ;

optional_else:
    /* vacio */ {
        fprintf(outfile, "LABEL %s\n", if_stack[i_top].label_end);
        pop_if();
    }
    | KW_OBSERVER block {
        fprintf(outfile, "LABEL %s\n", if_stack[i_top].label_end);
        pop_if();
    }
    ;

while_stmt:
    KW_REPEATER LPAREN {
        char *L_start = gen_label();
        fprintf(outfile, "LABEL %s\n", L_start);
        push_loop(L_start, NULL, NULL, NULL); 
    } condition RPAREN {
        char *L_end = gen_label();
        loop_stack[l_top].end = L_end;
        fprintf(outfile, "IFFALSE %s GOTO %s\n", $4, L_end);
    } block {
        fprintf(outfile, "GOTO %s\n", loop_stack[l_top].start);
        fprintf(outfile, "LABEL %s\n", loop_stack[l_top].end);
        pop_loop();
    }
    ;

for_stmt:
    KW_PISTON LPAREN var_decl {
        char *L_start = gen_label();
        fprintf(outfile, "LABEL %s\n", L_start);
        push_loop(L_start, NULL, NULL, NULL);
    } condition SEMICOLON {
        char *L_end = gen_label();
        char *L_body = gen_label();
        char *L_inc = gen_label();
        
        loop_stack[l_top].end = L_end;
        loop_stack[l_top].body = L_body;
        loop_stack[l_top].inc = L_inc;

        fprintf(outfile, "IFFALSE %s GOTO %s\n", $5, L_end);
        fprintf(outfile, "GOTO %s\n", L_body);
        fprintf(outfile, "LABEL %s\n", L_inc);
    } for_update RPAREN { 
        fprintf(outfile, "GOTO %s\n", loop_stack[l_top].start);
        fprintf(outfile, "LABEL %s\n", loop_stack[l_top].body);
    } block {
        fprintf(outfile, "GOTO %s\n", loop_stack[l_top].inc);
        fprintf(outfile, "LABEL %s\n", loop_stack[l_top].end);
        pop_loop();
    }
    ;

condition:
      expression EQ expression { $$=gen_temp(); fprintf(outfile, "EQ %s %s %s\n", $1, $3, $$); }
    | expression NEQ expression { $$=gen_temp(); fprintf(outfile, "NEQ %s %s %s\n", $1, $3, $$); }
    | expression LT expression { $$=gen_temp(); fprintf(outfile, "LT %s %s %s\n", $1, $3, $$); }
    | expression GT expression { $$=gen_temp(); fprintf(outfile, "GT %s %s %s\n", $1, $3, $$); }
    | expression LTE expression { $$=gen_temp(); fprintf(outfile, "LTE %s %s %s\n", $1, $3, $$); } /* NUEVO */
    | expression GTE expression { $$=gen_temp(); fprintf(outfile, "GTE %s %s %s\n", $1, $3, $$); } /* NUEVO */
    ;

expression:
    expression PLUS expression { $$=gen_temp(); fprintf(outfile, "ADD %s %s %s\n", $1, $3, $$); }
    | expression MINUS expression { $$=gen_temp(); fprintf(outfile, "SUB %s %s %s\n", $1, $3, $$); }
    | term
    ;

term:
    term MULT term { $$=gen_temp(); fprintf(outfile, "MUL %s %s %s\n", $1, $3, $$); }
    | term DIV term { $$=gen_temp(); fprintf(outfile, "DIV %s %s %s\n", $1, $3, $$); }
    | term MOD term { $$=gen_temp(); fprintf(outfile, "MOD %s %s %s\n", $1, $3, $$); }
    | factor
    ;

factor:
    LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | INT_LIT { $$ = $1; }
    | FLOAT_LIT { $$ = $1; }
    | STRING_LIT { $$ = $1; }
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
    fprintf(stderr, "Error de sintaxis en linea %d: %s\n", yylineno, s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Uso: %s <archivo.craft>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) return 1;
    outfile = fopen("output.fis", "w");
    fprintf(outfile, "// Codigo FIS-25 generado\n");
    yyparse();
    
    printf("Compilacion exitosa! Revisa output.fis\n");
    fclose(yyin);
    fclose(outfile);
    return 0;
}