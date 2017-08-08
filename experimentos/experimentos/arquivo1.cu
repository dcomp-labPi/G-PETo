#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "arquivo1.h"
#include "comm/comm.h"


__global__ void calculate(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] += d_buffer[ix];




}

extern "C" void funcao1(){

	int N =500;

	//printf("Funcao 1 \n");
	int *buffer, *d_buffer ;
	int i;

	//clock_t start,finish;
    	//double totaltime;

	dim3 grid, block;
	block.x = 1024;
	grid.x = (N + block.x - 1) / block.x;


	buffer = (int*) malloc(sizeof(int)*N*N);

	cudaMalloc(&d_buffer,sizeof(int)*N*N);

	for(i=0;i<N*N;i++){
		buffer[i] = i+1;
		//printf("%d\t",buffer[i]);
		
	}
	//printf("\n");


	cudaMemcpy(d_buffer,buffer,N*N*sizeof(int),cudaMemcpyHostToDevice);
	int j;
	//float mean = 0.0f;
	for(i=0;i<11;i++){
		//start = clock();
		
		//sendMessage("funcao1","funcao3", INT, (void*)d_buffer, N*N);
		//finish = clock();
		//totaltime=(double)(finish-start)/CLOCKS_PER_SEC; 
		//if(i>0) mean+=totaltime;
		//printf("Tempo iteração: %d Tempo: %f\n",i,totaltime);
		for(j=0;j<80000;j++){
			calculate<<<grid,block>>>(d_buffer);
			//compute_0(buffer,N*N);
		}

		sendMessage("funcao1","funcao2", INT, (void*)d_buffer, N*N);
		//sendMessage("funcao1","funcao2", INT, (void*)buffer, N*N);
	}
	//printf("Média final: %f\n",mean/10);

	//printf("Mensagem enviando...\n");
	//sendMessage("funcao1","funcao2", INT, (void*)buffer, 10);
	//sendMessage("funcao1","funcao3", INT, (void*)buffer, 10);
	//printf("Mensagem enviada...\n");
	
	
}
