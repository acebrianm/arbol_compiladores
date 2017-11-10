flex arbol.lex
bison -d arbol.y
gcc lex.yy.c arbol.tab.c -lfl -lm -o arbol
