#include <stdio.h>
#include <stdlib.h>
#include "arquivo2.h"
#include "comm/comm.h"


__global__ void compute1(int *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buffer[ix] = ix+1;




}



extern "C" void funcao2(){


	//printf("Funcao 2 \n");
	 FILE *arquivo;
	int N;
        arquivo = fopen("tamanho_vetor","r");

        fscanf(arquivo,"%d",&N);
	//printf("%d\n",N);
        //int N =500;
        fclose(arquivo);

	int *buffer,*d_buffer;
	int i,j;//,sum;


	dim3 grid, block;
	block.x = 1024;
	grid.x = (N + block.x - 1) / block.x;


	buffer = (int*) malloc(sizeof(int)*N);
	cudaMalloc(&d_buffer,sizeof(int)*N);
	//sum = 0;
	//for(i=0;i<11;i++){
		receiveMessage("funcao2","funcao1", INT, (void*)d_buffer, N);
		compute1<<<grid,block>>>(d_buffer);
		//receiveMessage("funcao2","funcao1", INT, (void*)buffer, N*N);

		//for(j=0;j<80000;j++){
			//compute1<<<grid,block>>>(d_buffer);
			//compute_1(buffer, N);
		//}
		//cudaMemcpy(buffer,d_buffer,N*N*sizeof(int),cudaMemcpyDeviceToHost);
		
		//for(j=0;j<N*N;j++){
		//	printf("%d\t",buffer[j]);
		//	sum = sum + buffer[j];
		//}
		//printf("\n");
		//printf("\tFuncao 2 -> Soma Parcial i=%d : %d\n",i,sum);
		//sendMessage("funcao2","funcao3", INT, (void*)d_buffer, N*N);
		//sendMessage("funcao2","funcao3", INT, (void*)buffer, N*N);
	//}

	//printf("Soma Função 2: %d\n",sum);

	//printf("Recebendo Mensagem...\n");
	//receiveMessage("funcao2","funcao1", INT, (void*)buffer, 10);
	//for(i=0;i<10;i++){
	//	printf("Buffer[%d]: %d\n",i,buffer[i]);
	//}
	//printf("Mensagem recebida...\n");
	

}