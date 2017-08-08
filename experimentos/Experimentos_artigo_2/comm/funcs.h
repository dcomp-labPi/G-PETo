#include "stdio.h"
#include <mpi.h>



#ifndef FUNCS_H
#define FUNCS_H
#ifdef __cplusplus
//extern "C" {
#endif

enum Type { SHORT, INT, LONG, LONG_LONG, UNSIGNED_CHAR, UNSIGNED_SHORT, UNSIGNED, UNSIGNED_LONG, UNSIGNED_LONG_LONG, FLOAT, DOUBLE, LONG_DOUBLE,BYTE};


void setDevice(int device);
void cpyToCPU(void *buffer,void *d_buffer,int size,Type tipo);
void cpyToGPU(void *buffer,void *d_buffer,int size,Type tipo);

#ifdef __cplusplus
//}
#endif

#endif
