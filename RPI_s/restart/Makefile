# Makefile
all: restart
	
restart: restart.o
	gcc -o $@ $+

restart.o : restart.s
	as -o $@ $<

clean:
	rm -vf restart *.o