/* Este archivo contiene un reconocedor de expresiones aritméticas junto
   con algunas reglas semánticas que calculan los valores de las
   expresiones que se reconocen. Las expresiones son muy sencillas y
   consisten únicamente de sumas, restas, multiplicaciones y divisiones de
   números enteros. 

   Autor: Alexandro Cebrian Mancera */

%{
#include<stdio.h>
#include<math.h>

#define STACK_MAX 50

int yylex();
extern char * yytext;
int yyerror(char const *);

typedef struct nodo{
    int tipo;
    int valor;

    struct nodo * izq;
    struct nodo * der;
}nodo;

nodo * creaNodo(int, int, nodo *, nodo *);
nodo * creaNodoNum(int, int);
void imprimeNodo(nodo *);
void recorreArbol(nodo *);
void calculaResultado(nodo *);

static nodo * inicio;

int size = -1;
int stack [STACK_MAX];
%}

/* Los elementos terminales de la gramática. La declaración de abajo se
   convierte en definición de constantes en el archivo calculadora.tab.h
   que hay que incluir en el archivo de flex. */

%token NUM SUMA RESTA MULTI DIVISION EXPONENTE MODULO PARENI PAREND FINEXP
%union{
	int entero;
	struct nodo * arbol;
}
%type <arbol> exp expr term factor
%type <entero> NUM
%start exp

%%

exp : expr FINEXP { inicio = $1; return 0;}
;

expr : expr SUMA term { $$ = creaNodo(1, '+', $1, $3); }
     | expr RESTA term { $$ = creaNodo(1, '-', $1, $3); }
	 | term { $$ = $1; }
;

term : term MULTI factor { $$ = creaNodo(1, '*', $1, $3); }
	 | term DIVISION factor { $$ = creaNodo(1, '/', $1, $3); }
	 | term EXPONENTE factor { $$ = creaNodo(1, '^', $1, $3); }
	 | term MODULO factor { $$ = creaNodo(1, '%', $1, $3); }
	 | factor { $$ = $1; }
;

factor : PARENI expr PAREND { $$ = $2; }
       | NUM { $$ = creaNodoNum(0, $1); }
;

%%

int yyerror(char const * s) {
  fprintf(stderr, "ERROR: %s YYTEXT: %s\n", s, yytext);
}

nodo * creaNodo(int tipo, int valor, nodo * izq, nodo * der){
	nodo * nuevo = (nodo*)malloc(sizeof(nodo));
	nuevo -> izq = izq;
	nuevo -> der = der;
	nuevo -> tipo = tipo;
	nuevo -> valor = valor;

	return nuevo;
}

nodo * creaNodoNum(int tipo, int valor){
	nodo * nuevo = (nodo*)malloc(sizeof(nodo));
	nuevo -> tipo = tipo;
	nuevo -> valor = valor;

	return nuevo;
}

void imprimeNodo(nodo * actual){
	if (actual){
		if (actual -> tipo == 1){
			printf("%c", actual -> valor);
		}
		else
			printf("%d", actual -> valor);
	}
}

void recorreArbol(nodo * inicio){
	if (inicio){
		recorreArbol(inicio -> izq);
		recorreArbol(inicio -> der);
		imprimeNodo(inicio);
	}
}

void push(int val){
	stack[++size] = val;
}

int pop(){
	return stack[size--];
}

void calculaResultado(nodo * inicio){
	int tmp;
	int res;
	if (inicio){
		calculaResultado(inicio -> izq);
		calculaResultado(inicio -> der);
		if (inicio -> tipo == 0)
			push(inicio -> valor);
		else{
			switch(inicio -> valor){
				case '+':
					tmp = pop();
					res = pop() + tmp;
					push(res);
					break;
				case '-':
					tmp = pop();
					res = pop() - tmp;
					push(res);
					break;
				case '*':
					tmp = pop();
					res = pop() * tmp;
					push(res);
					break;
				case '/':
					tmp = pop();
					res = pop() / tmp;
					push(res);
					break;
				case '^':
					tmp = pop();
					res = pow(pop(), tmp);
					push(res);
					break;
				case '%':
					tmp = pop();
					res = pop() % tmp;
					push(res);
					break;
			}
		}
	}
}

void main() {
	yyparse();
	recorreArbol(inicio);
	printf("\n");
	calculaResultado(inicio);
	printf("Resultado: %d\n", stack[size]);
}

