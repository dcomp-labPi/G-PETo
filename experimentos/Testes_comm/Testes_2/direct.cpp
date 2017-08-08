#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <unistd.h>
#include "func.h"

 
int main( int argc, char** argv )
{
    MPI_Init (&argc, &argv);
 
    int direct;
    int rank, size;
    int *h_buff = NULL;
    int *d_rank = NULL;
    int *d_buff = NULL;
    size_t bytes;
    int i;
	int n_proc;

	// 0 - MPI Padrão ; 1 - MPI P2P ; 2 - INTRA-Padrão; 3 - INTRA-P2P
	int tipo = atoi(argv[1]);
	size = atoi(argv[2]);

	char hostname[1024];
	gethostname(hostname, 1024);

//	printf("Hostname: %s\n",hostname);

 
    // Ensure that RDMA ENABLED CUDA is set correctly
    //direct = getenv("MPICH_RDMA_ENABLED_CUDA")==NULL?0:atoi(getenv ("MPICH_RDMA_ENABLED_CUDA"));
    //if(direct != 1){
    //    printf ("MPICH_RDMA_ENABLED_CUDA not enabled!\n");
     //   exit (EXIT_FAILURE);
    //}
 
    // Get MPI rank and size
    MPI_Comm_rank (MPI_COMM_WORLD, &rank);
    MPI_Comm_size (MPI_COMM_WORLD, &n_proc);
// printf("Hostname: %s rank: %d\n",hostname,rank);

    // Allocate host and device buffers and copy rank value to GPU
    bytes = size*sizeof(int);
    h_buff = (int*)malloc(bytes);
    
	if(rank==0){
		for(i=0;i<size;i++){
			h_buff[i] = i;
		}
	}

    // Preform Allgather using device buffer
    //MPI_Allgather(d_rank, 1, MPI_INT, d_buff, 1, MPI_INT, MPI_COMM_WORLD);

   /* if (world_rank == 0) {
    	number = -1;
    	MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
    } else if (world_rank == 1) {
    	MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Process 1 received number %d from process 0\n", number);
    }*/
 

	if(tipo==0){
		init(&d_buff,&d_rank,&rank,size);
		if(rank==0){
				MPI_standard(h_buff,d_buff,rank,size);
			//printf("Teste 1\n");
			//printf("rank %d Hostname: %s\n",rank,hostname);
			
				MPI_Send(h_buff, size, MPI_INT, 1, 123, MPI_COMM_WORLD);
			//printf("Teste 2\n");
		}
		else{
			//printf("Teste 3\n");
			//printf("rank %d Hostname: %s\n",rank,hostname);
				MPI_Recv(h_buff, size, MPI_INT, MPI_ANY_SOURCE, 123, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
				MPI_standard(h_buff,d_buff,rank,size);
			//printf("Teste 4\n");
			
		}
	}
	else if(tipo==1){
		init(&d_buff,&d_rank,&rank,size);
		if(rank==0){
				MPI_Send(d_buff, size, MPI_INT, 1, 123, MPI_COMM_WORLD);
		}
		else{
				MPI_Recv(d_buff, size, MPI_INT, 0, 123, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
				callKernel(d_buff,size);
		}
	}
	else if(tipo==2){
		if(rank!=0){
			transfer_intra_standard(size);
		}
	}
	else if(tipo==3){
		if(rank!=0){ 
			//printf("Antes de chamar a função no arquivo func.cu \n");
			transfer_intra_P2P(size);
		}
	}
	else if(tipo==4){
		if(rank!=0){
		}
	}
	

    // Check that the GPU buffer is correct

    
 
    // Clean up
    free(h_buff);
    clean(&d_buff,&d_rank);
    MPI_Finalize();
 
    return 0;
}
