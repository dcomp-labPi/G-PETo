#include <stdio.h>
#include "funcs.h"

extern "C"{
	void setDevice(int device){
		cudaSetDevice(device);
	}
}
