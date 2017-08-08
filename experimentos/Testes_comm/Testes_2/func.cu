#include <stdlib.h>
#include <stdio.h>

#define checkCuda(error) __checkCuda(error, __FILE__, __LINE__)


__global__ void kernel(int *d_buff, int size){

	int ix = blockIdx.x*blockDim.x + threadIdx.x;

	d_buff[ix] = ix+1;

}


extern "C" {

	inline void __checkCuda(cudaError_t error, const char *file, const int line){
	
		if (error != cudaSuccess){
			printf("checkCuda error at %s:%i: %s\n", file, line, cudaGetErrorString(cudaGetLastError()));
			exit(-1);
		}
	
		return;
	}

	void callKernel(int *d_buff,int size){

			dim3 grid, block;
                	block.x = 1024;
                        grid.x = (size + block.x - 1) / block.x;


                        kernel<<<block,grid>>>(d_buff,size);

                        //int *h2_buff;
                        //int i;
                        //h2_buff = (int*)malloc(size*sizeof(int));
                        //checkCuda(cudaMemcpy(h2_buff, d_buff,sizeof(int)*size,cudaMemcpyDeviceToHost));
                        //for(i=0;i<size;i++){
                        //        printf("%d\t",h2_buff[i]);
                       // }
                       // printf("\n");

	}


	void init(int **d_buff, int **d_rank,int *rank,int size){
		
		checkCuda(cudaMalloc((void**)d_buff,sizeof(int)*size));
		//checkCuda(cudaMalloc((void**)d_rank,sizeof(int)));
		//checkCuda(cudaMemcpy(*d_rank, rank,sizeof(int),cudaMemcpyHostToDevice));

	}

	void MPI_standard(int *h_buff,int *d_buff,int rank, int size){

		if(rank==0){
			checkCuda(cudaMemcpy(h_buff, d_buff,sizeof(int)*size,cudaMemcpyDeviceToHost));	
		}else{
			checkCuda(cudaMemcpy(d_buff, h_buff,sizeof(int)*size,cudaMemcpyHostToDevice));


			dim3 grid, block;
	                block.x = 1024;
        	        grid.x = (size + block.x - 1) / block.x;

			
			kernel<<<block,grid>>>(d_buff,size);

                	//int *h2_buff;
			//int i;
                	//h2_buff = (int*)malloc(size*sizeof(int));
                	//checkCuda(cudaMemcpy(h2_buff, d_buff,sizeof(int)*size,cudaMemcpyDeviceToHost));
                	//for(i=0;i<size;i++){
                        //	printf("%d\t",h2_buff[i]);
                	//}
                	//printf("\n");
		}

	}

	void transfer_intra_P2P(int n_buffer){

		int gpu1 = 0;
		int gpu2 = 1;
		int *d_buffer;
		int *d2_buffer;
		int i;

		//int nDevices;

  		//cudaGetDeviceCount(&nDevices);

		//printf("Number of Devices: %d\n",nDevices);


		dim3 grid, block;
		block.x = 1024;
		grid.x = (n_buffer + block.x - 1) / block.x;
		
		//printf("Antes de criar stream_0\n");
		checkCuda(cudaSetDevice(gpu1));
		cudaStream_t stream_0;
		checkCuda(cudaStreamCreate(&stream_0));
		//printf("Antes de alocar d_buffer\n");
		checkCuda(cudaMalloc(&d_buffer,sizeof(int)*n_buffer));

		checkCuda(cudaSetDevice(gpu2));
		//printf("Antes de alocar d2_buffer\n");
		checkCuda(cudaMalloc(&d2_buffer,sizeof(int)*n_buffer));
		//printf("Antes de entrar no for que envia os pacotes\n");
		for(i=0;i<1;i++){
			//printf("Entrei no for i: %d \n",i);
			checkCuda(cudaMemcpyPeerAsync(d2_buffer,gpu2,d_buffer,gpu1,n_buffer*sizeof(int),stream_0));
			cudaDeviceSynchronize();
		
			kernel<<<block,grid>>>(d2_buffer,n_buffer);
			
		}
		
		checkCuda(cudaFree(d2_buffer));
		checkCuda(cudaSetDevice(gpu1));
                checkCuda(cudaFree(d_buffer));
           
		
		//int *h2_buff;
		//h2_buff = (int*)malloc(n_buffer*sizeof(int));
		//checkCuda(cudaMemcpy(h2_buff, d2_buffer,sizeof(int)*n_buffer,cudaMemcpyDeviceToHost));
		//for(i=0;i<n_buffer;i++){
		//	printf("%d\t",h2_buff[i]);
		//}
		//printf("\n");

	}

	void transfer_intra_standard(int n_buffer){

		int gpu1 = 0;
		int gpu2 = 1;
		int *d_buffer;
		int *d2_buffer;
		int *buffer;
		int i;
	
		dim3 grid, block;
                block.x = 1024;
                grid.x = (n_buffer + block.x - 1) / block.x;



		buffer = (int*) malloc(sizeof(int)*n_buffer);


		checkCuda(cudaSetDevice(gpu1));
		checkCuda(cudaMalloc(&d_buffer,sizeof(int)*n_buffer));
		//checkCuda(cudaMemcpy(buffer,d_buffer,n_buffer*sizeof(int),cudaMemcpyDeviceToHost));

		checkCuda(cudaSetDevice(gpu2));
		checkCuda(cudaMalloc(&d2_buffer,sizeof(int)*n_buffer));
		//checkCuda(cudaMemcpy(d2_buffer,buffer,n_buffer*sizeof(int),cudaMemcpyHostToDevice));

		for(i=0;i<1;i++){
			checkCuda(cudaSetDevice(gpu1));
			checkCuda(cudaMemcpy(buffer,d_buffer,n_buffer*sizeof(int),cudaMemcpyDeviceToHost));
			checkCuda(cudaSetDevice(gpu2));
			checkCuda(cudaMemcpy(d2_buffer,buffer,n_buffer*sizeof(int),cudaMemcpyHostToDevice));
			kernel<<<block,grid>>>(d2_buffer,n_buffer);
			cudaDeviceSynchronize();
		}
		checkCuda(cudaSetDevice(gpu1));
		checkCuda(cudaFree(d_buffer));
		checkCuda(cudaSetDevice(gpu2));
		checkCuda(cudaFree(d2_buffer));

                //int *h2_buff;
		//int i;
                //h2_buff = (int*)malloc(n_buffer*sizeof(int));
                //checkCuda(cudaMemcpy(h2_buff, d2_buffer,sizeof(int)*n_buffer,cudaMemcpyDeviceToHost));
                //for(i=0;i<n_buffer;i++){
                //        printf("%d\t",h2_buff[i]);
                //}
                //printf("\n");

	}

	void setDevice(int device){
		cudaSetDevice(device);
	}

	void getResult(int *d_buff, int *h_buff,int size){

		checkCuda(cudaMemcpy(h_buff,d_buff,size*sizeof(int),cudaMemcpyDeviceToHost));

	}

	void clean(int **d_buff, int **d_rank){
		checkCuda(cudaFree(*d_buff));
		checkCuda(cudaFree(*d_rank));
	}


}
