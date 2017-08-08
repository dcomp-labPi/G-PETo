#include <stdio.h>
#include <stdlib.h>


__global__ void calculate(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] += d_buffer[ix];


	__syncthreads();


}


__global__ void compute1(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] = d_buffer[ix]*2;


	__syncthreads();


}

__global__ void compute2(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] = d_buffer[ix]*10;


	__syncthreads();


}

int main(int argc, char *argv[]){


	int *matriz_1,*matriz_2,*h_matriz;

	int N,i,j,iter;

	int loop;

	//dimensão da matriz
	N = atoi(argv[1]);
	//numero de iterações
	iter = atoi(argv[2]);
	
	loop = atoi(argv[3]);	
	
	h_matriz = (int*) malloc(sizeof(int)*N*N);

	cudaMalloc(&matriz_1,sizeof(int)*N*N);

	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			h_matriz[i*N+j] = (i*N+j)+1;
		}
	}

	cudaMemcpy(matriz_1,h_matriz,N*N*sizeof(int),cudaMemcpyHostToDevice);

	dim3 grid, block;
	block.x = 1024;
	grid.x = (N + block.x - 1) / block.x;

	for(i=0;i<iter;i++){
		for(j=0;j<loop;j++){
			calculate<<<grid,block>>>(matriz_1);
		}
		for(j=0;j<loop;j++){
			compute1<<<grid,block>>>(matriz_1);
		}
		for(j=0;j<loop;j++){
			compute2<<<grid,block>>>(matriz_1);
		}
		

	}


	return 0;
}











