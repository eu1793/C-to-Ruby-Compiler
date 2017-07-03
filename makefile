all: flex bison gcc

flex:
	flex lexical.l

bison:
	bison -yd syntactical.y

gcc:
	gcc lex.yy.c y.tab.c -o CtoRuby

clean:
	rm lexical.l syntactical.y lex.yy.c y.tab.c y.tab.h makefile
