#include <stdio.h>
#include <cuda_runtime.h>

#ifndef FUNC_H
#define FUNC_H
#ifdef __cplusplus
extern "C"{
#endif

void callKernel(int *d_buff,int size);

void init(int **d_buff,int **d_rank,int *rank,int size);

void MPI_standard(int *h_buff,int *d_buff,int rank, int size);

void transfer_intra_P2P(int n_buffer);

void transfer_intra_standard(int n_buffer);

void getResult(int *d_buff, int *h_buff,int size);

void clean(int **d_buff, int **d_rank);


#ifdef __cplusplus
}
#endif
#endif
