#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <mpi.h>
#include <unistd.h>
#include "funcs.h"

//#include "comm.h"


typedef void (*libFunc)();


int main(int argc, char **argv){


	MPI_Init (&argc, &argv);


	int rank, size;

	// Get MPI rank and size
	MPI_Comm_rank (MPI_COMM_WORLD, &rank);
	MPI_Comm_size (MPI_COMM_WORLD, &size);


	char hostname[1024];
        gethostname(hostname, 1024);

	

	void *ptrLib;
	ptrLib = dlopen("/home/labpi/Dropbox/Experimentos_MPI/libfw.so",RTLD_LAZY);
	FILE *functions_names_file, *rank_map_file, *ranks_per_device;

	functions_names_file = fopen("/home/labpi/Dropbox/Experimentos_MPI/functions_names","r");
	rank_map_file = fopen("/home/labpi/Dropbox/Experimentos_MPI/comm/rank_map","w");
	ranks_per_device = fopen("/home/labpi/Dropbox/Experimentos_MPI/comm/config","r");
	
	if (functions_names_file == NULL) {
       		perror("Error");
    	}


	int *ranks_device;
	int i,device;
	ranks_device = (int*) malloc(sizeof(int)*size);
	for(i=0;i<size;i++){
		fscanf(ranks_per_device,"%d",&device);
		fscanf(ranks_per_device,"%d",&device);
		ranks_device[i] = device;
	}


	


	char *function_name;
	
	char **matrix;
	int N;

	fscanf(functions_names_file,"%d",&N);
	matrix = (char**) malloc(N*sizeof(char*));
	for (i=0;i<N;i++){
		matrix[i] = (char*) malloc(32*sizeof(char));
	}

	for (i=0;i<N;i++){
		fscanf(functions_names_file,"%s",matrix[i]);
		
	}
	fprintf(rank_map_file,"%d\n",N);
	for(i=0;i<N;i++){
		fprintf(rank_map_file,"%s\n",matrix[i]);
	}
	fclose(rank_map_file);

	libFunc function = (libFunc) dlsym(ptrLib, matrix[rank]);
	if (function == NULL) { 
		fprintf(stderr, "Couldn't find function: %s Hostname: %s Rank: %d \n",matrix[rank],hostname,rank); 
		return 1;
	}
	else{
		setDevice(ranks_device[rank]);
		function();
	}
	


 	fclose(functions_names_file);
	
	MPI_Finalize();
	
	

	return 0;
 
}
