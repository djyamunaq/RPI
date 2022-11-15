# Makefile
all: server
	

server: server.o
	gcc -o $@ $+

server.o : server.s
	as -o $@ $<

clean:
	rm -vf server *.o