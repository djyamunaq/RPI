# Makefile
all: walking_pixel
	

walking_pixel: walking_pixel.o
	python ../clear.py && gcc -o $@ $+

walking_pixel.o : walking_pixel.s
	as -o $@ $<

clean:
	rm -vf walking_pixel *.o