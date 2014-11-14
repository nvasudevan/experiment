CSS_LEX="css.lex"
CSS_YACC="../unambiguous/yacc/css.y"

all: css

css: css.lex.o css.tab.o 
	gcc -g -o css css.lex.o css.tab.o -lfl

css.lex.o: css.tab.c css.lex.c 
	gcc -g -c css.lex.c -o css.lex.o

css.tab.c: 
	bison -d ${CSS_YACC}

css.lex.c: 
	flex -o css.lex.c ${CSS_LEX}

css.tab.o: css.tab.c
	gcc -g -c css.tab.c -o css.tab.o

clean: 
	rm -rf *.c *.h *.o css

