D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
//#include "y.tab.h"

#define TOKEN_EOF 0
#define TOKEN_IDENTIFICATEUR 300
#define TOKEN_CONSTANTE 301
#define TOKEN_VOID 302
#define TOKEN_INT 303
#define TOKEN_FOR 304
#define TOKEN_WHILE 305
#define TOKEN_IF 306
#define TOKEN_ELSE 307
#define TOKEN_SWITCH 308
#define TOKEN_CASE 309
#define TOKEN_DEFAULT 310


/* Ne gère pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"auto"                  { /* A completer */ }
"break"                 { /* A completer */ }
"case"                  { return TOKEN_CASE; }
"char"                  { /* A completer */ }
"const"                 { /* A completer */ }
"continue"              { /* A completer */ }
"default"               { return TOKEN_DEFAULT; }
"do"                    { /* A completer */ }
"double"                { /* A completer */ }
"else"                  { return TOKEN_ELSE; }
"enum"                  { /* A completer */ }
"extern"                { /* A completer */ }
"float"                 { /* A completer */ }
"for"                   { return TOKEN_FOR; }
"goto"                  { /* A completer */ }
"if"                    { return TOKEN_IF; }
"int"                   { return TOKEN_INT; }
"long"                  { /* A completer */ }
"register"              { /* A completer */ }
"return"                { /* A completer */ }
"short"                 { /* A completer */ }
"signed"                { /* A completer */ }
"sizeof"                { /* A completer */ }
"static"                { /* A completer */ }
"struct"                { /* A completer */ }
"switch"                { return TOKEN_SWITCH; }
"typedef"               { /* A completer */ }
"union"                 { /* A completer */ }
"unsigned"              { /* A completer */ }
"void"                  { return TOKEN_VOID; }
"volatile"              { /* A completer */ }
"while"                 { return TOKEN_WHILE; }

{L}({L}|{D})*           { /* A completer */ }

0[xX]{H}+{IS}?          { /* A completer */ }
0{D}+{IS}?              { /* A completer */ }
{D}+{IS}?               { /* A completer */ }
L?'(\\.|[^\\'])+'       { /* A completer */ }

{D}+{E}{FS}?            { /* A completer */ }
{D}*"."{D}+({E})?{FS}?  { /* A completer */ }
{D}+"."{D}*({E})?{FS}?  { /* A completer */ }

L?\"(\\.|[^\\"])*\"     { /* A completer */ }

"..."                   { /* A completer */ }
">>="                   { /* A completer */ }
"<<="                   { /* A completer */ }
"+="                    { /* A completer */ }
"-="                    { /* A completer */ }
"*="                    { /* A completer */ }
"/="                    { /* A completer */ }
"%="                    { /* A completer */ }
"&="                    { /* A completer */ }
"^="                    { /* A completer */ }
"|="                    { /* A completer */ }
">>"                    { /* A completer */ }
"<<"                    { /* A completer */ }
"++"                    { /* A completer */ }
"--"                    { /* A completer */ }
"->"                    { /* A completer */ }
"&&"                    { /* A completer */ }
"||"                    { /* A completer */ }
"<="                    { /* A completer */ }
">="                    { /* A completer */ }
"=="                    { /* A completer */ }
"!="                    { /* A completer */ }

[ \t\v\n\f]             {  }
.                       { return yytext[0]; }
%%

yywrap() {}

int main() {
	int token;
	do {
		token = yylex();
		printf("%d\n", token);
	} while (token != TOKEN_EOF);
	return 0;
}

