#include <stdio.h>
#include "ast.h"
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

    // 1. Parsing (Construir AST)
    printf("1. Analizando sintaxis...\n");
    yyparse();

    // 2. Generacion de Codigo
    printf("2. Generando codigo para el simulador FIS-25...\n");
    FILE* out = fopen("output.fis", "w");
    fprintf(out, "// Codigo para el simulador FIS-25 Generado (Arquitectura AST)\n");
    generate_code(root, out);
    
    printf("Exito Codigo guardado en output.fis\n");
    
    fclose(yyin);
    fclose(out);
    // free_ast(root); // Opcional: limpiar memoria
    return 0;
}