# Makefile
all: pixel_remote_server
	
pixel_remote_server: pixel_remote_server.o
	python ../clear.py && gcc -o $@ $+

pixel_remote_server.o : pixel_remote_server.s
	as -o $@ $<

clean:
	rm -vf pixel_remote_server *.o