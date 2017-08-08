#include "comm.h"

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

void sendMessage(char *origem,char *destino, Type tipo, void *buffer, int size){
	MPI_Datatype mpi_rgba_type =  create_mpi_rgba();
	
	int i,dest,N,ori,tag;
	int rank;
	FILE *file_map_rank;
	char **matrix;

	file_map_rank = fopen("./comm/rank_map","r");
	fscanf(file_map_rank,"%d",&N);
	
	matrix =  (char**) malloc(N*sizeof(char*));

	for (i=0;i<N;i++){
		matrix[i] = (char*) malloc(32*sizeof(char));
	}

	for(i=0;i<N;i++){
		fscanf(file_map_rank,"%s",matrix[i]);
	}
	fclose(file_map_rank);

	for(i=0;i<N;i++){
		if(strcmp(destino,matrix[i])==0){
			dest = i;
			break;
		}
	}

	for(i=0;i<N;i++){
		if(strcmp(origem,matrix[i])==0){
			ori = i;
			break;
		}
	}

	switch(tipo){
		case SHORT:
			printf("TODO\n");
			break;
		case INT:
			
			int *data;
			data = (int*)buffer;
			MPI_Comm_rank (MPI_COMM_WORLD, &rank);
			//printf("Rank Send : %d rank atual: %d destino: %s\n",dest,rank,destino);
			tag = ori*13 + dest*17;
			MPI_Send(buffer, size, MPI_INT,dest, tag, MPI_COMM_WORLD);
			break;
		case LONG:
			printf("TODO\n");
			break;
		case LONG_LONG: 
			printf("TODO\n");
			break;
		case UNSIGNED_CHAR:
			printf("TODO\n");
			break;
		case UNSIGNED_SHORT:
			printf("TODO\n");
			break;
		case UNSIGNED:
			printf("TODO\n");
			break;
		case UNSIGNED_LONG:
			printf("TODO\n");
			break;
		case UNSIGNED_LONG_LONG:
			printf("TODO\n");
			break;
		case FLOAT:
			printf("TODO\n");
			break;
		case DOUBLE:
			printf("TODO\n");
			break;
		case LONG_DOUBLE:
			printf("TODO\n");
			break;
		case BYTE:
			printf("TODO\n");
			break;
		case MPI_RGBA:
			RGBA *dados;
			dados = (RGBA*)buffer;
			//printf("Defini o buffer\n");
			MPI_Comm_rank (MPI_COMM_WORLD, &rank);
			//printf("Rank Send : %d rank atual: %d destino: %s\n",dest,rank,destino);
			tag = ori*13 + dest*17;
			//printf("%d %d type %d %d MpiCommWorld\n",buffer==NULL,size,dest,tag);
			MPI_Send(buffer, size, mpi_rgba_type,dest, tag, MPI_COMM_WORLD);
			break;
	}
	for (i=0;i<N;i++){
		free(matrix[i]);
	}free(matrix);
	MPI_Type_free(&mpi_rgba_type);
}

void receiveMessage(char *destino,char *origem, Type tipo, void *buffer, int size){
	MPI_Datatype mpi_rgba_type =  create_mpi_rgba();

	int i,ori,N,dest,tag;
	FILE *file_map_rank;
	char **matrix;
	int rank;

	file_map_rank = fopen("./comm/rank_map","r");
	fscanf(file_map_rank,"%d",&N);
	
	matrix =  (char**) malloc(N*sizeof(char*));

	for (i=0;i<N;i++){
		matrix[i] = (char*) malloc(32*sizeof(char));
	}

	for(i=0;i<N;i++){
		fscanf(file_map_rank,"%s",matrix[i]);
	}
	fclose(file_map_rank);

	for(i=0;i<N;i++){
		if(strcmp(origem,matrix[i])==0){
			ori = i;
			break;
		}
	}

	for(i=0;i<N;i++){
		if(strcmp(destino,matrix[i])==0){
			dest = i;
			break;
		}
	}

	switch(tipo){

		case SHORT:
			printf("TODO\n");
			break;
		case INT:
			int *data;
			data = (int*) buffer;
			MPI_Comm_rank (MPI_COMM_WORLD, &rank);
			//printf("Rank Recv : %d rank atual: %d origem: %s\n",ori,rank,origem);
			tag = ori*13 + dest*17;
			MPI_Recv(buffer, size, MPI_INT, ori, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
			break;
		case LONG:
			printf("TODO\n");
			break;
		case LONG_LONG: 
			printf("TODO\n");
			break;
		case UNSIGNED_CHAR:
			printf("TODO\n");
			break;
		case UNSIGNED_SHORT:
			printf("TODO\n");
			break;
		case UNSIGNED:
			printf("TODO\n");
			break;
		case UNSIGNED_LONG:
			printf("TODO\n");
			break;
		case UNSIGNED_LONG_LONG:
			printf("TODO\n");
			break;
		case FLOAT:
			printf("TODO\n");
			break;
		case DOUBLE:
			printf("TODO\n");
			break;
		case LONG_DOUBLE:
			printf("TODO\n");
			break;
		case BYTE:
			printf("TODO\n");
			break;
		case MPI_RGBA:
			RGBA *dados;
			dados = (RGBA*) buffer;
			MPI_Comm_rank (MPI_COMM_WORLD, &rank);
			//printf("Rank Recv : %d rank atual: %d origem: %s\n",ori,rank,origem);
			tag = ori*13 + dest*17;
			MPI_Recv(buffer, size, mpi_rgba_type, ori, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
			break;
	}
	for (i=0;i<N;i++){
		free(matrix[i]);
	}free(matrix);
	MPI_Type_free(&mpi_rgba_type);
}


 

