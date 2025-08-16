all: clean tac a.out

tac: tac.l tac.y
	bison -d tac.y
	flex tac.l
	g++ -w -o tac tac.tab.c lex.yy.c -lfl

a.out: a3.l a3.y
	bison -d a3.y
	flex a3.l
	g++ -w -o a.out a3.tab.c lex.yy.c -lfl

clean:
	rm -f tac.tab.c lex.yy.c tac.tab.h a.out tac a3.tab.c a3.tab.h 
