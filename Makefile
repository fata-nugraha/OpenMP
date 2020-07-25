CC=gcc-9

mpi : src/openmp.c
	$(CC) -g -Wall -o prog src/openmp.c -fopenmp

clean : 
	rm prog
