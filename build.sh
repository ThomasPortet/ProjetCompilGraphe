lex lex.l
yacc -d yacc.y
gcc -o executable y.tab.c lex.yy.c
rm y.tab.c lex.yy.c
