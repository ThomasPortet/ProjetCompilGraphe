%{
#include <stdio.h>
#include <stdlib.h>
%}
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
		liste_declarations liste_fonctions { printf("Programme!\n"); }
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
		IDENTIFICATEUR { printf("Déclaration!\n"); }
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' { printf("Fonction!\n"); }
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' { printf("Fonction externe!\n"); }
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
		variable '=' expression { printf("Affectation!\n"); }
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';' { printf("Appel de fonction!\n"); }
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

yywrap() {}

int yyerror(char* s) {
	fprintf(stderr, "%s\n", s);
}

int main() {
	return yyparse();
}
