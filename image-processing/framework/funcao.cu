#include "funcao.h"

/*===================== KERNEL CUDA ====================================================================*/
__global__ void sepia(RGBA *d_buffer){
    int id = blockIdx.x*blockDim.x + threadIdx.x;
    d_buffer[id].r = (d_buffer[id].r * 0.393f) + (d_buffer[id].g * 0.769f) + (d_buffer[id].b * 0.189f);
    d_buffer[id].g = (d_buffer[id].r * 0.349f) + (d_buffer[id].g * 0.686f) + (d_buffer[id].b * 0.168f);
    d_buffer[id].b = (d_buffer[id].r * 0.272f) + (d_buffer[id].g * 0.534f) + (d_buffer[id].b * 0.131f);
}

__global__ void negative(RGBA *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;
	d_buffer[ix].r = 255 - d_buffer[ix].r;
	d_buffer[ix].g = 255 - d_buffer[ix].g;
	d_buffer[ix].b = 255 - d_buffer[ix].b;
}

__global__ void grayscale(RGBA *d_buffer){
	int ix = blockIdx.x*blockDim.x + threadIdx.x;
	int luminosidade = d_buffer[ix].r + d_buffer[ix].g + d_buffer[ix].b;

	d_buffer[ix].r = luminosidade/3;
	d_buffer[ix].g = luminosidade/3;
	d_buffer[ix].b = luminosidade/3;
}
/*===================== KERNEL CUDA ====================================================================*/

int size = 150*100;
int quantidade = 5000;
char img_name[] = "150*100.png";
/*=============================== Envia ===============================*/
extern "C" void funcaoEnv1(){
	MPI_Datatype mpi_rgba_type = create_mpi_rgba();

	clock_t start,end; start=clock();

	PNG_DATA *arquivo = read_png_file(img_name);
	RGBA *pixels = translate_px_to_vec(arquivo);

	sendMessage("funcaoEnv1","funcaoProc1", MPI_RGBA, pixels, size);
	receiveMessage("funcaoEnv1","funcaoProc1",MPI_RGBA,pixels,size);

	//translate_vec_to_px(pixels,arquivo);
	//write_png_file("saida.png",arquivo);
	end = clock();

	printf("F1: %lf\n",(double)(end - start) / CLOCKS_PER_SEC);
	MPI_Type_free(&mpi_rgba_type);
}
/*============================== Processadores =====================================*/

void processa_vetor_pixel(RGBA *buffer, int size, int device, int op){
	cudaSetDevice(device);
	RGBA *d_buffer;
	cudaMalloc((void **)&d_buffer,sizeof(RGBA)*size);
	cudaMemcpy(d_buffer, buffer,(size*sizeof(RGBA)),cudaMemcpyHostToDevice);

	int i;
	for(i=0; i<200; i++){
		if(op==0){
			sepia<<<size/512,512>>>(d_buffer);
		}else if (op == 1){
			negative<<<size/512,512>>>(d_buffer);
		}else if (op == 2){
			grayscale<<<size/512,512>>>(d_buffer);
		}
	}
	cudaMemcpy(buffer, d_buffer, (size*sizeof(RGBA)), cudaMemcpyDeviceToHost);
	cudaFree(d_buffer);
}

extern "C" void funcaoProc1(){
	int i;

	RGBA *buffer = (RGBA*)malloc(sizeof(RGBA)*size);
	//printf("F1 %d\n",quantidade);
	receiveMessage("funcaoProc1","funcaoEnv1",MPI_RGBA,buffer,size);
	processa_vetor_pixel(buffer,size,0,0);
	sendMessage("funcaoProc1","funcaoProc2",MPI_RGBA,buffer,size);

	for( i=0;i < quantidade-1; i++){
		buffer = (RGBA*)malloc(sizeof(RGBA)*size);
		receiveMessage("funcaoProc1","funcaoProc3",MPI_RGBA,buffer,size);
		processa_vetor_pixel(buffer,size,0,0);
		sendMessage("funcaoProc1","funcaoProc2",MPI_RGBA,buffer,size);
	}

	receiveMessage("funcaoProc1","funcaoProc3",MPI_RGBA,buffer,size);
	sendMessage("funcaoProc1","funcaoEnv1",MPI_RGBA,buffer,size);
}

extern "C" void funcaoProc2(){
	int i;
	//printf("F2 %d\n",quantidade);

	for( i=0; i < quantidade; i++){
		RGBA *buffer = (RGBA*)malloc(sizeof(RGBA)*size);
		receiveMessage("funcaoProc2","funcaoProc1",MPI_RGBA,buffer,size);
		processa_vetor_pixel(buffer,size,1,1);
		sendMessage("funcaoProc2","funcaoProc3",MPI_RGBA,buffer,size);
	}
}

extern "C" void funcaoProc3(){
	int i;
	//printf("F3 %d\n",quantidade);
	
	for( i=0;i < quantidade; i++){
		RGBA *buffer = (RGBA*)malloc(sizeof(RGBA)*size);
		receiveMessage("funcaoProc3","funcaoProc2",MPI_RGBA,buffer,size);
		processa_vetor_pixel(buffer,size,0,2);
		sendMessage("funcaoProc3","funcaoProc1",MPI_RGBA,buffer,size);
	}
}
