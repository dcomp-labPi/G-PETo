#ifndef COMM_H
#define COMM_H

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <mpi.h>
#include <unistd.h>
#include <string.h> 

typedef struct{
	int r;
	int g;
	int b;
	int a;
}RGBA;

enum Type { SHORT, INT, LONG, LONG_LONG, UNSIGNED_CHAR, UNSIGNED_SHORT, UNSIGNED, UNSIGNED_LONG, UNSIGNED_LONG_LONG, FLOAT, DOUBLE, LONG_DOUBLE, BYTE, MPI_RGBA};

extern MPI_Datatype create_mpi_rgba();

extern void sendMessage(char *origem,char *destino, enum Type tipo, void *buffer, int size);

extern void receiveMessage(char *destino,char *origem, enum Type tipo, void *buffer, int size);

#endif
