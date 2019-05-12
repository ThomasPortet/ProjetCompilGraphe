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
%type <node> fonction liste_instructions instruction bloc expression affectation variable variable_tableau binary_op saut appel liste_expressions liste_expressions_interne condition selection selection_switch iteration binary_rel binary_comp
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
		iteration { $$ = $1; }
	|	selection { $$ = $1; }
	|	saut { $$ = $1; }
	|	affectation ';' { $$ = $1; }
	|	bloc { $$ = $1; }
	|	appel { $$ = $1; }
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction {
$$ = makenode("[label=\"FOR\"]");
$3->right = $5;
$5->right = $7;
$7->right = $9;
$$->child = $3;
}
	|	WHILE '(' condition ')' instruction {
$$ = makenode("[label=\"WHILE\"]");
$3->right = $5;
$$->child = $3;
}
;
selection	:	
		IF '(' condition ')' instruction %prec THEN {
$$ = makenode("[label=\"IF\" shape=diamond]");
$3->right = $5;
$$->child = $3;
}
	|	IF '(' condition ')' instruction ELSE instruction {
$$ = makenode("[label=\"IF\" shape=diamond]");
$3->right = $5;
$5->right = $7;
$$->child = $3;
}
	|	SWITCH '(' expression ')' '{' selection_switch '}' {
$$ = makenode("[label=\"SWITCH\"]");
$$->child = reverse($6);
}
;
selection_switch	:
		selection_switch CASE CONSTANTE ':' liste_instructions {
char* buffer = NULL;
asprintf(&buffer, "[label=\"CASE\"]");//"[label=\"CASE %s\"]", $3 pour avoir les numéros sur les cases
node_t* node = makenode(buffer);
node->right = $1;
node->child = reverse($5);
$$ = node;
}
	|	selection_switch DEFAULT ':' liste_instructions {
node_t* node = makenode("[label=\"DEFAULT\"]");
node->right = $1;
node->child = reverse($4);
$$ = node;
}
	|	{ $$ = NULL; }
;
saut	:	
		BREAK ';' { $$ = makenode("[label=\"BREAK\" shape=box]"); }
	|	RETURN ';' { $$ = makenode("[label=\"RETURN\" shape=trapezium color=blue]"); }
	|	RETURN expression ';' {
$$ = makenode("[label=\"RETURN\" shape=trapezium color=blue]");
$$->child = $2;
}
;
affectation	:	
		variable '=' expression{
        node_t* node_affect = makenode("[label=\":=\"]");
        node_t* node_var = $1;
        node_affect->child=node_var;
        node_var->right=$3;
        $$=node_affect;
        }
;
bloc	:	
		'{' liste_declarations liste_instructions '}' {
node_t* node = makenode("[label=\"BLOC\"]");
node->child = reverse($3);
$$ = node;
}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';' {
char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\" shape=septagon]", $1);
$$ = makenode(buffer);
$$->child = reverse($3);
}
;
variable	:	
		IDENTIFICATEUR {
char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\"]", $1);
$$ = makenode(buffer);
}
	|	variable_tableau '[' expression ']' {
$$ = makenode("[label=\"TAB\"]");
$3->right = $1;
$$->child = reverse($3);
}
;
variable_tableau	:
		IDENTIFICATEUR {
char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\"]", $1);
$$ = makenode(buffer);
}
	|	variable_tableau '[' expression ']' { $3->right = $1; $$ = $3; }
;
expression	:	
		'(' expression ')' { $$ = $2; }
	|	binary_op %prec OP { $$ = $1; }
	|	MOINS expression  { node_t* node_minus = makenode("[label= \"-\"]");
        node_minus->child=$2;
        $$ = node_minus; }
	|	CONSTANTE {char* buffer = NULL;
        asprintf(&buffer, "[label=\"%s\"]", $1); $$ = makenode(buffer);  }
	|	variable { $$ = $1; }
	|	IDENTIFICATEUR '(' liste_expressions ')' {
char* buffer = NULL;
asprintf(&buffer, "[label=\"%s\" shape=septagon]", $1);
$$ = makenode(buffer);
$$->child = reverse($3);
}
;
liste_expressions	:	
		liste_expressions_interne { $$ = $1; }
	| { $$ = NULL; }
;
liste_expressions_interne	:	
		liste_expressions_interne ',' expression { $3->right = $1; $$ = $3; }
	|	expression { $$ = $1; }
;
condition	:	
		NOT '(' condition ')' { $$ = makenode("[label=\"!\"]"); $$->child = $3; }
	|	condition binary_rel condition %prec REL { $1->right = $3; $2->child = $1; $$ = $2; }
	|	'(' condition ')' { $$ = $2; }
	|	expression binary_comp expression { $1->right = $3; $2->child = $1; $$ = $2; }
;
binary_op	:	
		expression PLUS expression %prec PLUS {
    node_t* node_b = makenode("[label= \"+\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|   expression MOINS expression %prec MOINS {
    node_t* node_b = makenode("[label= \"-\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|	expression MUL expression %prec MUL {
    node_t* node_b = makenode("[label= \"*\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|	expression DIV expression %prec DIV {
    node_t* node_b = makenode("[label= \"/\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|   expression LSHIFT expression %prec LSHIFT {
    node_t* node_b = makenode("[label= \"<<\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|   expression RSHIFT expression %prec RSHIFT {
    node_t* node_b = makenode("[label= \">>\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|	expression BAND expression %prec BAND {
    node_t* node_b = makenode("[label= \"&\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
	|	expression BOR expression %prec BOR {
    node_t* node_b = makenode("[label= \"|\"]"); 
    node_t* node_l = $1;
    node_b->child=node_l;
    node_l->right=$3;
    $$=node_b;}
;
binary_rel	:	
		LAND { $$ = makenode("[label= \"&&\"]"); }
	|	LOR { $$ = makenode("[label= \"||\"]"); }
;
binary_comp	:	
		LT { $$ = makenode("[label= \"<\"]"); }
	|	GT { $$ = makenode("[label= \">\"]"); }
	|	GEQ { $$ = makenode("[label= \">=\"]"); }
	|	LEQ { $$ = makenode("[label= \"<=\"]"); }
	|	EQ { $$ = makenode("[label= \"==\"]"); }
	|	NEQ { $$ = makenode("[label= \"!=\"]"); }
;
%%

int yywrap() {}



//Noeuds

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

node_t* reverse_(node_t* node, node_t* next) {
	if (next == NULL) return node;
	node_t* ret = reverse_(next, next->right);
	next->right = node;
	return ret;
}

node_t* reverse(node_t* node) {
	if (node == NULL) return NULL;
	node_t* ret = reverse_(node, node->right);
	node->right = NULL;
	return ret;
}

//Liste

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
	printlist(list->next);
	printnode(list->val);
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
