#include <stdlib.h>
#include <stdio.h>
//#include <mpi.h>
#include <png.h>

#define checkCuda(error) __checkCuda(error, __FILE__, __LINE__)

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

    // Read any color_type into 8bit depth, RGBA format.
    // See http://www.libpng.org/pub/png/libpng-manual.txt

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

int size=150*100;
int testSize = 1000;
int processar = 400;

int main(int argc, char *argv[]){  
	int cont = 0;  
	int gpu1 = 0;
	int gpu2 = 1;
	RGBA *d1_buffer;
	RGBA *d2_buffer;
	RGBA* result;

	clock_t start,end;
	start=clock();    

	char test[] = "150x100.png";
	PNG_DATA* imageData = read_png_file(test);

	cudaSetDevice(gpu1);
	cudaMalloc(&d1_buffer, (size*sizeof(RGBA)));
	cudaSetDevice(gpu2);
	cudaMalloc(&d2_buffer, (size*sizeof(RGBA)));
	cudaMalloc(&result, (size*sizeof(RGBA)));

	while (cont < testSize) {
		cudaSetDevice(gpu1);  

		//cudaStream_t stream_0;
		//cudaStreamCreate(&stream_0);

		//cudaMalloc(&d1_buffer, (size*sizeof(RGBA)));

		//RGBA* result = translate_px_to_vec(imageData);
		result = translate_px_to_vec(imageData);
		
		//cudaSetDevice(gpu2);
		//cudaMalloc(&d2_buffer, (size*sizeof(RGBA)));

		cudaMemcpyPeer(d2_buffer, gpu2, result, gpu1, (size*sizeof(RGBA)));
		cudaDeviceSynchronize();
		
		cudaSetDevice(gpu2);
		for (int i = 0; i < processar/2; i++){
			
			sepia<<<size/512,512>>>(d2_buffer);
			
			cudaMemcpyPeer(d1_buffer, gpu1, d2_buffer, gpu2, (size*sizeof(RGBA)));
			cudaDeviceSynchronize();
			
			cudaSetDevice(gpu1); 
			negative<<<size/512,512>>>(d1_buffer);
			
			cudaMemcpyPeer(d2_buffer, gpu2, d1_buffer, gpu1, (size*sizeof(RGBA)));
			cudaDeviceSynchronize();
			
			cudaSetDevice(gpu2);
		}
		
		cudaMemcpy(result,d2_buffer,(size*sizeof(RGBA)),cudaMemcpyDeviceToHost);
		translate_vec_to_px(result,imageData); 

		cont++;

		char test[16];
		sprintf(test,"finalteste1.png");
		write_png_file(test,imageData);
	}


	cudaFree(d1_buffer);
	cudaSetDevice(gpu2);
	cudaFree(d2_buffer);
	cudaFree(result);
	

    end = clock();
    double duration = (double)(end - start) / CLOCKS_PER_SEC;
    printf("EXECUTION_TIME = %f\n",duration);



}
