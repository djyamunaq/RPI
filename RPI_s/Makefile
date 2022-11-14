# Makefile
all: write_pixel
	

write_pixel: write_pixel.o
	python ../RPI_py/clear.py && gcc -o $@ $+

write_pixel.o : write_pixel.s
	as -o $@ $<

clean:
	rm -vf write_pixel *.o