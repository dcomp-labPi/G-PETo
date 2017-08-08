#include <stdio.h>
#include <stdlib.h>
#include "arquivo3.h"
#include "comm/comm.h"


__global__ void compute3(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] = d_buffer[ix]*10;


	__syncthreads();


}


extern "C" void funcao4(){


	int N=500;
	int *buffer,*d_buffer;
	int i,j,sum;


	dim3 grid, block;
	block.x = 1024;
	grid.x = (N + block.x - 1) / block.x;


	buffer = (int*) malloc(sizeof(int)*N*N);
	cudaMalloc(&d_buffer,sizeof(int)*N*N);
	
	sum = 0;
	for(i=0;i<11;i++){
		receiveMessage("funcao4","funcao3", INT, (void*)d_buffer, N*N);
		for(j=0;j<100000;j++){
			compute3<<<grid,block>>>(d_buffer);
		}
		//sendMessage("funcao4","funcao5", INT, (void*)d_buffer, N*N);
		
		//cudaMemcpy(buffer,d_buffer,N*N*sizeof(int),cudaMemcpyDeviceToHost);
		//for(j=0;j<N*N;j++){
		//	sum = sum + buffer[j];
		//}
	}

	//printf("Soma Função 3: %d\n",sum);


	//printf("Recebendo Mensagem...\n");
	//receiveMessage("funcao3","funcao1", INT, (void*)buffer, 10);
	//for(i=0;i<10;i++){
	//	printf("Buffer[%d]: %d\n",i,buffer[i]);
	//}
	//printf("Mensagem recebida...\n");
	

}
