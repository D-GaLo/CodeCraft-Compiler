%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h" 

void yyerror(const char *s);
int yylex();
%}

%option noyywrap
%option yylineno

%%

"//".* { }
[ \t\n\r]               { }

"item"                  { return KW_ITEM; }
"redstone"              { return TYPE_REDSTONE; }
"boat"                  { return TYPE_BOAT; }
"tourch"                { return TYPE_BOOL; }
"text"                  { return TYPE_TEXT; }
"void"                  { return TYPE_VOID; }
"inventory"             { return TYPE_INVENTORY; }

"circuit"               { return KW_CIRCUIT; }
"drop"                  { return KW_DROP; }
"comparator"            { return KW_COMPARATOR; }
"observer"              { return KW_OBSERVER; }
"hopper"                { return KW_HOPPER; }
"repeater"              { return KW_REPEATER; }
"piston"                { return KW_PISTON; }

"new_inventory"         { return KW_NEW_INV; }
"store"                 { return KW_STORE; }
"stack_size"            { return KW_SIZE; }

"chat"                  { return KW_CHAT; }
"glowstone"             { return KW_GLOWSTONE; }
"pressure_plate"        { return KW_PRESSURE; }
"lever"                 { return KW_LEVER; }

">="                    { return GTE; }
"<="                    { return LTE; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"<"                     { return LT; }
">"                     { return GT; }
"="                     { return ASSIGN; }

"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return MULT; }
"/"                     { return DIV; }
"%"                     { return MOD; }
"^"                     { return POW; }

"("                     { return LPAREN; }
")"                     { return RPAREN; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
"["                     { return LBRACKET; }
"]"                     { return RBRACKET; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }

[0-9]+                  { yylval.sval = strdup(yytext); return INT_LIT; }
[0-9]+\.[0-9]+          { yylval.sval = strdup(yytext); return FLOAT_LIT; }
\"[^"]*\"               { yylval.sval = strdup(yytext); return STRING_LIT; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return ID; }

.                       { printf("Error lexico en linea %d: Caracter '%s' no reconocido\n", yylineno, yytext); }

%%