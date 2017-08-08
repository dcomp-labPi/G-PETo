#include <png.h>
#include "comm/comm.h"

typedef struct{
    int size;
    int width, height;
    png_byte color_type;
    png_byte bit_depth;
    png_bytep *row_pointers;
    RGBA* pixels;
}PNG_DATA;

void copy_pixels(RGBA *position, png_bytep px2);

void copy_positions(RGBA position, png_bytep px2);

RGBA* translate_px_to_vec(PNG_DATA* dados);

void translate_vec_to_px(RGBA* input, PNG_DATA* dados);

/*** Leitura e escrita no png ***/
PNG_DATA* read_png_file(char *filename);

void write_png_file(char *filename, PNG_DATA* dados);