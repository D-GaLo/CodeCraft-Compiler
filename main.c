#include <stdio.h>
#include "ast.h"
#include "semantic.h"
#include "codegen.h"

extern FILE* yyin;
extern ASTNode* root;
extern int yyparse();

int main(int argc, char** argv) {
    if (argc != 2) {
        printf("Uso: %s <archivo.craft>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Error al abrir archivo.\n");
        return 1;
    }

    printf("1. Analizando sintaxis...\n");
    if (yyparse() != 0) {
        printf("Error de sintaxis. Abortando.\n");
        return 1;
    }

    printf("2. Verificando semantica (tipos y variables)...\n");
    if (semantic_analysis(root) != 0) {
        printf("Compilacion fallida debido a errores semanticos.\n");
        return 1;
    }

    printf("3. Generando codigo para el simulador...\n");
    FILE* out = fopen("output.fis", "w");
    fprintf(out, "// Codigo para usar en el simulador \n");
    generate_code(root, out);
    
    printf("Exito! Codigo guardado en output.fis\n");
    
    fclose(yyin);
    fclose(out);
    return 0;
}