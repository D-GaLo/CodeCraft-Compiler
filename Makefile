all: compiler

compiler: parser.tab.c lex.yy.c ast.c semantic.c codegen.c main.c
	gcc -o codecraft_compiler parser.tab.c lex.yy.c ast.c semantic.c codegen.c main.c -lfl

parser.tab.c: parser.y
	bison -d parser.y

lex.yy.c: lexer.l
	flex lexer.l

clean:
	rm -f codecraft_compiler parser.tab.c parser.tab.h lex.yy.c output.fis