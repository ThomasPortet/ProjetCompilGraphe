%{
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include "compi.h"
int yylex();
int yyerror(char* s) {
	fprintf(stderr, "%s\n", s);
}

list_t* listprogramme;

%}
%union {
char *nom;
struct _node_t *node;
struct _list_t *list;
}

%token <nom> IDENTIFICATEUR CONSTANTE
%token VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
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

%type <list> liste_fonctions
%type <node> fonction liste_instructions instruction bloc expression affectation variable
%type <nom> type

%start programme
%%
programme	:	
		liste_declarations liste_fonctions { listprogramme = $2; }
;
liste_declarations	:	
		liste_declarations declaration 
	|	
;
liste_fonctions	:	
		liste_fonctions fonction { $$ = cons($2, $1); }
|               fonction { $$ = cons($1, NULL); }
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
		type IDENTIFICATEUR '(' liste_parms ')' bloc { 
char* buffer = NULL;
asprintf(&buffer, "[label=\"%s, %s\" shape=invtrapezium color=blue]", $2, $1);
$$ = makenode(buffer);
$$->child = $6;
}
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' { $$ = NULL; }
;
type	:	
		VOID { $$ = "void"; }
	|	INT { $$ = "int"; }
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
		liste_instructions instruction { $2->right = $1; $$ = $2; }
	| { $$ = NULL; }
;
instruction	:	
		iteration { $$ = makenode(""); }
	|	selection { $$ = makenode(""); }
	|	saut { $$ = makenode(""); }
	|	affectation ';' { $$ = $1; }
	|	bloc { $$ = $1; }
	|	appel { $$ = makenode(""); }
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
		variable '=' expression{
        node_t* node_affect = makenode("[label=\":=\" shape=ellipse]");
        node_t* node_var = $1;
        node_affect->child=node_var;
        node_var->right=$3;
        $$=node_affect;
        }
;
bloc	:	
		'{' liste_declarations liste_instructions '}' {
node_t* node = makenode("[label=\"BLOC\"]");
node->child = $3;
$$ = node;
}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';' 
;
variable	:	
		IDENTIFICATEUR {char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\"]", $1); $$ = makenode(buffer); }
	|	variable '[' expression ']' { $$ = makenode(""); }
;
expression	:	
		'(' expression ')' { $$ = makenode(""); }
	|	expression binary_op expression %prec OP { $$ = makenode(""); }
	|	MOINS expression  { $$ = makenode(""); }
	|	CONSTANTE {char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\"]", $1); $$ = makenode(buffer);  }
	|	variable { $$ = makenode(""); }
	|	IDENTIFICATEUR '(' liste_expressions ')' { $$ = makenode(""); }
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
	free(node->carac);
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

	printf("digraph generated {\n");
	printlist(listprogramme);
	printf("}\n");
	freelist(listprogramme);

	return res;
}
