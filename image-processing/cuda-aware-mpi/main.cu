#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>
#include <png.h>

typedef struct {
    int r;
    int g;
    int b;
    int a;
} RGBA;

typedef struct{
    int size;
    int width, height;
    png_byte color_type;
    png_byte bit_depth;
    png_bytep *row_pointers;
    RGBA* pixels;
}PNG_DATA;

void copy_pixels(RGBA *position, png_bytep px2){
    position->r = px2[0];
    position->g = px2[1];
    position->b = px2[2];
    position->a = px2[3];
}

void copy_positions(RGBA position, png_bytep px2){
    px2[0] = position.r;
    px2[1] = position.g;
    px2[2] = position.b;
    px2[3] = position.a;
}

RGBA* translate_px_to_vec(PNG_DATA* dados) {
    int x,y;
    int height = dados->height;
    int width = dados->width;
    RGBA *pixels = (RGBA*)malloc(sizeof(RGBA)* dados->size);
    for (y = 0; y < height; y++) {
        png_bytep row = dados->row_pointers[y];
        for (x = 0; x < width; x++) {
            png_bytep px = &(row[x * 4]);
            copy_pixels(&(pixels[y*width+x]),px);
        }
    }
    return pixels;
}

void translate_vec_to_px(RGBA* input, PNG_DATA* dados){
    int x,y;
    int height = dados->height;
    int width = dados->width;
    for (y = 0; y < height; y++) {
        png_bytep row = dados->row_pointers[y];
        for (x = 0; x < width; x++) {
            png_bytep px = &(row[x * 4]);
            copy_positions(input[y*width+x],px);
        }
    }
}



/*** Leitura e escrita no png ***/
PNG_DATA* read_png_file(char *filename) {
    int y;
    PNG_DATA *novo = (PNG_DATA*)malloc(sizeof(PNG_DATA));
    FILE *fp = fopen(filename, "rb");

    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info = png_create_info_struct(png);
    if (!png || !info)
        abort();

    if (setjmp(png_jmpbuf(png)))
        abort();

    png_init_io(png, fp);

    png_read_info(png, info);

    novo->width = png_get_image_width(png, info);
    novo->height = png_get_image_height(png, info);
    novo->size = novo->width*novo->height;
    novo->color_type = png_get_color_type(png, info);
    novo->bit_depth = png_get_bit_depth(png, info);

    if (novo->bit_depth == 16)
        png_set_strip_16(png);

    if (novo->color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png);

    // PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth.
    if (novo->color_type == PNG_COLOR_TYPE_GRAY && novo->bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png);

    if (png_get_valid(png, info, PNG_INFO_tRNS))
        png_set_tRNS_to_alpha(png);

    // These color_type don't have an alpha channel then fill it with 0xff.
    if (novo->color_type == PNG_COLOR_TYPE_RGB || novo->color_type == PNG_COLOR_TYPE_GRAY ||
            novo->color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_filler(png, 0xFF, PNG_FILLER_AFTER);

    if (novo->color_type == PNG_COLOR_TYPE_GRAY ||
            novo->color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png);

    png_read_update_info(png, info);

    novo->row_pointers = (png_bytep *)malloc(sizeof(png_bytep) * novo->height);
    for (y = 0; y < novo->height; y++) {
        novo->row_pointers[y] = (png_byte *)malloc(png_get_rowbytes(png, info));
    }

    png_read_image(png, novo->row_pointers);

    fclose(fp);
    return novo;
}

void write_png_file(char *filename, PNG_DATA* dados) {
    
    int width = dados->width;
    int height = dados->height;

    FILE *fp = fopen(filename, "wb");
    if (!fp)
        abort();

    png_structp png =
            png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png)
        abort();

    png_infop info = png_create_info_struct(png);
    if (!info)
        abort();

    if (setjmp(png_jmpbuf(png)))
        abort();

    png_init_io(png, fp);

    // Output is 8bit depth, RGBA format.
    png_set_IHDR(png, info, width, height, 8, PNG_COLOR_TYPE_RGBA,
                             PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT,
                             PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png, info);

    // To remove the alpha channel for PNG_COLOR_TYPE_RGB format,
    // Use png_set_filler().
    // png_set_filler(png, 0, PNG_FILLER_AFTER);

    png_write_image(png, dados->row_pointers);
    png_write_end(png, NULL);

    /*for (y = 0; y < height; y++) {
        free(dados->row_pointers[y]);
    }*/
    //free(dados->row_pointers);

    fclose(fp);
}

/*=============================================================================================*/

__global__ void grayscale(RGBA *pixels){
    int id = blockIdx.x*blockDim.x + threadIdx.x;   
    int result = 0.21f * pixels[id].r + 0.72f * pixels[id].g + 0.07f * pixels[id].b;
    pixels[id].r = pixels[id].g = pixels[id].b = result;
}
__global__ void negative(RGBA *pixels){
    int id = blockIdx.x*blockDim.x + threadIdx.x;   
    pixels[id].r = 255-pixels[id].r;
    pixels[id].g = 255-pixels[id].g;
    pixels[id].b = 255-pixels[id].b;
}

__global__ void sepia(RGBA *pixels){
    int id = blockIdx.x*blockDim.x + threadIdx.x;   
    pixels[id].r = (pixels[id].r * 0.393f) + (pixels[id].g * 0.769f) + (pixels[id].b * 0.189f);
    pixels[id].g = (pixels[id].r * 0.349f) + (pixels[id].g * 0.686f) + (pixels[id].b * 0.168f);
    pixels[id].b = (pixels[id].r * 0.272f) + (pixels[id].g * 0.534f) + (pixels[id].b * 0.131f);
}

MPI_Datatype create_mpi_rgba(){
	// Criacao do tipo de dado do mpi para o RGBA *
    const int nitens = 4;
    int blocklengths[4] = {1,1,1,1};
    MPI_Datatype types[4] = {MPI_INT,MPI_INT,MPI_INT,MPI_INT};
    MPI_Datatype mpi_rgba_type;
    MPI_Aint offsets[4];
    offsets[0] = offsetof(RGBA,r);
    offsets[1] = offsetof(RGBA,g);
    offsets[2] = offsetof(RGBA,b);
    offsets[3] = offsetof(RGBA,a);
    MPI_Type_create_struct(nitens,blocklengths,offsets,types,&mpi_rgba_type);
    MPI_Type_commit(&mpi_rgba_type);
	return mpi_rgba_type;
    // Termino da criacao do tipo do mpi para o rgba *
}


int size = 150*100;
int testSize = 5000;
int filterSize = 200;

int main(int argc, char *argv[]){    
    
    MPI_Init(&argc, &argv);

    

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);        
    MPI_Datatype mpi_rgba_type = create_mpi_rgba();              
    clock_t start,end;
    start=clock();    
    if (world_rank == 0) {        
               
        PNG_DATA* imageData = read_png_file("150x100.png");
        RGBA* result = translate_px_to_vec(imageData);
        
        
        int countControle = 0;
        //(countSend<testSize || countReceived<testSize) && 
        //printf("ProcID %d vai enviar imagem%d para %d (%d).\n",world_rank,0,1,world_size);                
        MPI_Send(result,size,mpi_rgba_type,1,0,MPI_COMM_WORLD);
        //printf("ProcID %d enviou imagem%d para %d (%d).\n",world_rank,0,1,world_size);                
        
        MPI_Recv(result, size,mpi_rgba_type,3, 10, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        
        /*translate_vec_to_px(result,imageData);            
        char test[19];
        s//printf(test,"output/image.png");
        write_png_file(test,imageData);
        end = clock();
        double duration = (double)(end - start) / CLOCKS_PER_SEC;
        //printf("EXECUTION_TIME = %f\n",duration);    */    
        
        MPI_Type_free(&mpi_rgba_type);
        MPI_Finalize();
        
        
    } else if(world_rank == 1){        
        MPI_Status status;     
        RGBA* result = (RGBA*) malloc(sizeof(RGBA)*size);   
        //printf("ProcID %d vai receber imagem%d de %d (%d).\n",world_rank,0,0,world_size);                     
        MPI_Recv(result, size,mpi_rgba_type,0, 0, MPI_COMM_WORLD, &status);
        //printf("ProcID %d vai recebeu imagem%d de %d (%d).\n",world_rank,0,0,world_size);                     
        for(int countControle = 0;countControle<testSize;countControle++){                        
            cudaSetDevice(0);
            RGBA* d_result;
            
            cudaMalloc((void **) &d_result,(size*sizeof(RGBA)));
            cudaMemcpy(d_result,result,(size*sizeof(RGBA)),cudaMemcpyHostToDevice);
            for(int i=0;i<filterSize;i++){ //divido por 2 pois cada repetição executa 2 filtros                    
                sepia<<<size/512,512>>>(d_result);                                
            }
            cudaMemcpy(result,d_result,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);
            //printf("ProcID %d vai enviar imagem%d para %d (%d).\n",world_rank,0,2,world_size);                     
            MPI_Send(result,size,mpi_rgba_type,2,10,MPI_COMM_WORLD);                            
            //printf("ProcID %d vai enviaou imagem%d para %d (%d).\n",world_rank,0,2,world_size);  
            if(countControle < (testSize-1)){
                RGBA* result = (RGBA*) malloc(sizeof(RGBA)*size);        
                //printf("ProcID %d vai receber imagem%d de %d (%d).\n",world_rank,0,3,world_size);                     
                
                MPI_Recv(result, size,mpi_rgba_type,3, 10, MPI_COMM_WORLD, &status);
                //printf("ProcID %d vai recebeu imagem%d de %d (%d).\n",world_rank,0,3,world_size);                     
            }                   
        }
        MPI_Finalize();
    }else if(world_rank == 2){
        for(int countControle = 0;countControle<testSize;countControle++){                        
            cudaSetDevice(1);
            RGBA* result = (RGBA*) malloc(sizeof(RGBA)*size);        
            MPI_Status status; 
            //printf("ProcID %d vai receber imagem%d para %d (%d).\n",world_rank,0,1,world_size);                         
            MPI_Recv(result, size,mpi_rgba_type,1, 10, MPI_COMM_WORLD, &status);            
            RGBA* d_result;
            
            cudaMalloc((void **) &d_result,(size*sizeof(RGBA)));
            cudaMemcpy(d_result,result,(size*sizeof(RGBA)),cudaMemcpyHostToDevice);
            //printf("ProcID %d vai recebeu imagem%d para %d (%d).\n",world_rank,0,1,world_size);                         
            for(int i=0;i<filterSize;i++){ //divido por 2 pois cada repetição executa 2 filtros                    
                negative<<<size/512,512>>>(d_result);                                
                //cudaMemcpy(result,d_result,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);                
            }
            cudaMemcpy(result,d_result,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);
            
           // MPI_Abort(MPI_COMM_WORLD,MPI_SUCCESS);
            //printf("ProcID %d vai enviar imagem%d para %d (%d).\n",world_rank,0,3,world_size);                                                
            MPI_Send(result,size,mpi_rgba_type,3,10,MPI_COMM_WORLD);     
            //printf("ProcID %d vai enviou imagem%d para %d (%d).\n",world_rank,0,3,world_size);                                                
        }
        MPI_Finalize();

    }else if(world_rank == 3){

        for(int countControle = 0;countControle<testSize;countControle++){                        
            cudaSetDevice(0);
        
            RGBA* result = (RGBA*) malloc(sizeof(RGBA)*size);        
            MPI_Status status; 
            RGBA* d_result;    
            //printf("ProcID %d vai receber imagem%d para %d (%d).\n",world_rank,0,2,world_size);                                                    
            MPI_Recv(result, size,mpi_rgba_type,2, 10, MPI_COMM_WORLD, &status);            
            cudaMalloc((void **) &d_result,(size*sizeof(RGBA)));
            cudaMemcpy(d_result,result,(size*sizeof(RGBA)),cudaMemcpyHostToDevice);            
            
            //printf("ProcID %d vai recebeu imagem%d para %d (%d).\n",world_rank,0,2,world_size);                                                    
            for(int i=0;i<filterSize;i++){ //divido por 2 pois cada repetição executa 2 filtros                    
                grayscale<<<size/512,512>>>(d_result);                                
            }
            
            
            if(countControle < (testSize-1)){        
                //printf("ProcID %d vai enviar imagem%d para %d (%d).\n",world_rank,0,1,world_size);    
                cudaMemcpy(result,d_result,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);                                                
                MPI_Send(result,size,mpi_rgba_type,1,10,MPI_COMM_WORLD);                            
                //printf("ProcID %d vai enviou imagem%d para %d (%d).\n",world_rank,0,1,world_size);                                                    
            }else{
                //cudaMemcpy(result,d_result,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);        
                //MPI_Send(result,size,mpi_rgba_type,0,10,MPI_COMM_WORLD);                                    
            }
        }        
        end = clock();
        double duration = (double)(end - start) / CLOCKS_PER_SEC;
        printf("EXECUTION_TIME = %f\n",duration); 
        MPI_Abort(MPI_COMM_WORLD,MPI_SUCCESS);                
    }
    return 0;
}
