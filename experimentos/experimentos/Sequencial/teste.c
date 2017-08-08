#include <stdlib.h>
#include <stdio.h>


void soma(int **matriz,int N){


	int i,j;
	
	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			(*matriz)[i*N+j] = (*matriz)[i*N+j]+(*matriz)[i*N+j];
		}
	}

}


void multiplicaDois(int **matriz,int N){


	int i,j;
	
	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			(*matriz)[i*N+j] = (*matriz)[i*N+j]*2;
		}
	}


}


void multiplicaDez(int **matriz,int N){

	int i,j;
	
	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			(*matriz)[i*N+j] = (*matriz)[i*N+j]*10;
		}
	}

}


int main(int argc, char *argv[]){


	int *matriz_1,*matriz_2;

	int N,i,j,iter,loop;

	//dimensão da matriz
	N = atoi(argv[1]);
	//numero de iterações
	iter = atoi(argv[2]);
	loop = atoi(argv[3]);

	matriz_1 = (int*) malloc(sizeof(int)*N*N);

	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			matriz_1[i*N+j] = (i*N+j)+1;
		}
	}

	for(i=0;i<iter;i++){
		for(j=0;j<loop;j++){
			multiplicaDois(&matriz_1,N);
		}
		for(j=0;j<loop;j++){
			multiplicaDois(&matriz_1,N);
		}
		for(j=0;j<loop;j++){
			multiplicaDez(&matriz_1,N);
		}

	}


	return 0;
}
