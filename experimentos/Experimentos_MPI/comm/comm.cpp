#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <mpi.h>
#include <unistd.h>
#include <string.h>
#include "comm.h"


void sendMessage(char *origem,char *destino, Type tipo, void *buffer, int size){
	
	
	int i,dest,N,ori,tag;
	FILE *file_map_rank;
	char **matrix;

	file_map_rank = fopen("/home/labpi/Dropbox/Experimentos_MPI/comm/rank_map","r");
	fscanf(file_map_rank,"%d",&N);
	
	matrix =  (char**) malloc(N*sizeof(char*));

	for (i=0;i<N;i++){
		matrix[i] = (char*) malloc(32*sizeof(char));
	}

	for(i=0;i<N;i++){
		fscanf(file_map_rank,"%s",matrix[i]);
	}

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
			int rank;
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


	}
	



}


void receiveMessage(char *destino,char *origem, Type tipo, void *buffer, int size){


	int i,ori,N,dest,tag;
	FILE *file_map_rank;
	char **matrix;

	file_map_rank = fopen("/home/labpi/Dropbox/Experimentos_MPI/comm/rank_map","r");
	fscanf(file_map_rank,"%d",&N);
	
	matrix =  (char**) malloc(N*sizeof(char*));

	for (i=0;i<N;i++){
		matrix[i] = (char*) malloc(32*sizeof(char));
	}

	for(i=0;i<N;i++){
		fscanf(file_map_rank,"%s",matrix[i]);
	}

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
			int rank;
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


	}



}


 

