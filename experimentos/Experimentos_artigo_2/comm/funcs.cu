#include <stdio.h>
#include <stdlib.h>

#include "funcs.h"


//extern "C"{

	void setDevice(int device){
		cudaSetDevice(device);
		
	}

	void cpyToCPU(void *buffer,void *d_buffer,int size,Type tipo){
		if(tipo == INT){
			int *d_buffer_local,*buffer_local;
			d_buffer_local = (int*)d_buffer;
			buffer_local = (int*)buffer;
			cudaMemcpy(buffer_local,d_buffer_local,sizeof(int)*size,cudaMemcpyDeviceToHost);
		}
		else if(tipo == FLOAT){
			float *d_buffer_local_2,*buffer_local_2;
                        d_buffer_local_2 = (float*)d_buffer;
                        buffer_local_2 = (float*)buffer;
			cudaMemcpy(buffer_local_2,d_buffer_local_2,sizeof(float)*size,cudaMemcpyDeviceToHost);
		}
	}

	void cpyToGPU(void *buffer, void *d_buffer, int size, Type tipo){
		if(tipo == INT){
			int *d_buffer_local,*buffer_local;
                        d_buffer_local = (int*)d_buffer;
                        buffer_local = (int*)buffer;
			
			cudaMemcpy(d_buffer_local,buffer_local,size*sizeof(int),cudaMemcpyHostToDevice);
		}
		else if(tipo == FLOAT){
			float *d_buffer_local_2,*buffer_local_2;
                        d_buffer_local_2 = (float*)d_buffer;
                        buffer_local_2 = (float*)buffer;
			cudaMemcpy(d_buffer_local_2,buffer_local_2,size*sizeof(float),cudaMemcpyHostToDevice);
		}
	}

//}
