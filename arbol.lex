/* Autor: Alexandro Cebrian Mancera */
%{
#include "arbol.tab.h"
%}

NUM0 [0-9]
NUM1 [1-9]

%%

"+"             {return SUMA;}
"-"             {return RESTA;}
"*"             {return MULTI;}
"/"             {return DIVISION;}
"^"             {return EXPONENTE;}
"%"             {return MODULO;}
"("             {return PARENI;}
")"             {return PAREND;}
"$"             {return FINEXP;}

0|{NUM1}{NUM0}*  {yylval.entero = atoi(yytext); return NUM;}
%%
