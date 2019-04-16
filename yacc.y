%{
#include <stdio.h>
#include <stdlib.h>
#include "compi.h"


%}
%union {
struct node_t *node;
struct list_t *list;
}

%token IDENTIFICATEUR CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token GEQ LEQ EQ NEQ NOT EXTERN

%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL

%start programme
%%
programme	:	
		liste_declarations liste_fonctions
;
liste_declarations	:	
		liste_declarations declaration 
	|	
;
liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs ';'
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur
	|	declarateur
;
declarateur	:	
		IDENTIFICATEUR
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:	
		VOID
	|	INT
;
liste_parms	:	
		liste_parms_interne
	|	
;
liste_parms_interne	:
		liste_parms_interne ',' parm
	|	parm
;
parm	:	
		INT IDENTIFICATEUR
;
liste_instructions :	
		liste_instructions instruction
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:	
		BREAK ';'
	|	RETURN ';'
	|	RETURN expression ';'
;
affectation	:	
		variable '=' expression
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
		IDENTIFICATEUR
	|	variable '[' expression ']'
;
expression	:	
		'(' expression ')'
	|	expression binary_op expression %prec OP
	|	MOINS expression
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'
;
liste_expressions	:	
		liste_expressions_interne
	|
;
liste_expressions_interne	:	
		liste_expressions_interne ',' expression
	|	expression
;
condition	:	
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:	
		PLUS
	|       MOINS
	|	MUL
	|	DIV
	|       LSHIFT
	|       RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:	
		LAND
	|	LOR
;
binary_comp	:	
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%

int yywrap() {}

int yyerror(char* s) {
	fprintf(stderr, "%s\n", s);
}

int lastlabel = 0;

int nextlabel() {
	return lastlabel++;
}

node_t* makenode(char* carac) {
	node_t *node;
	node = (node_t*) malloc(sizeof(node_t));
	node->label = nextlabel();
	node->carac = carac;
	return node;
}

void freenode(node_t* node) {
	if (node == NULL) return;
	freenode(node->child);
	freenode(node->right);
	free(node);
}

void printnode(node_t* node) {
	if (node == NULL) return;
	printf("%d %s\n", node->label, node->carac);
	for (node_t* n = node->child; n != NULL; n = n->right) {
		printnode(n);
		printf("%d -> %d\n", node->label, n->label);
	}
}

list_t* cons(node_t* node, list_t* list) {
	list_t *newlist;
	newlist = (list_t*) malloc(sizeof(list_t));
	newlist->val = node;
	newlist->next = list;
	return newlist;
}
void freelist(list_t* list) {
	if (list == NULL) return;
	freelist(list->next);
	free(list);
}
void printlist(list_t* list) {
	if (list == NULL) return;
	printnode(list->val);
	printlist(list->next);
}

int main() {
	int res = yyparse();
	if (res != 0) return res;
	
	node_t* a = makenode("[label=\"a\"]");
	node_t* b = makenode("[label=\"b\"]");
	node_t* c = makenode("[label=\"c\"]");
	node_t* d = makenode("[label=\"d\"]");
	node_t* e = makenode("[label=\"e\"]");
	
	a->child = b;
	b->child = d;
	b->right = c;

	list_t* l = cons(a, cons(e, NULL));

	printf("digraph generated {\n");
	printlist(l);
	printf("}\n");
	freelist(l);

	return res;
}
