D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]

%{
#include <stdio.h>
//#include "y.tab.h"

#define T_EOF 0
#define IDENTIFICATEUR 300
#define CONSTANTE 301
#define VOID 302
#define INT 303
#define FOR 304
#define WHILE 305
#define IF 306
#define ELSE 307
#define SWITCH 308
#define CASE 309
#define DEFAULT 310
#define BREAK 311
#define RETURN 312
#define PLUS 313
#define MOINS 314
#define MUL 315
#define DIV 316
#define LSHIFT 317
#define RSHIFT 318
#define BAND 319
#define BOR 320
#define LAND 321
#define LOR 322
#define LT 323
#define GT 324
#define GEQ 325
#define LEQ 326
#define EQ 327
#define NEQ 328
#define NOT 329
#define EXTERN 330


/* Ne gère pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"switch"                { return SWITCH; }
"void"                  { return VOID; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFICATEUR; }

{D}+                    { return CONSTANTE; }

">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }
"&&"                    { return LAND; }
"||"                    { return LOR; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

"+"                     { return PLUS; }
"-"                     { return MOINS; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"&"                     { return BAND; }
"|"                     { return BOR; }

[ \t\v\n\f]             {  }
.                       { return yytext[0]; }
%%

yywrap() {}

int main() {
	int token;
	do {
		token = yylex();
		printf("%d\n", token);
	} while (token != T_EOF);
	return 0;
}

