#ifndef CODEGEN_H
#define CODEGEN_H
#include <stdio.h>
#include "ast.h"

void generate_code(ASTNode* node, FILE* out);

#endif