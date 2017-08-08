#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cusparse.h>
#include <cublas_v2.h>

// Utilities and system includes
#include "arquivo2.h"
#include "comm/comm.h"
#include "comm/funcs.h"

const char *sSDKname2     = "conjugateGradient";

/* genTridiag: generate a random tridiagonal symmetric matrix */
void genTridiag_2(int *I, int *J, float *val, int N, int nz)
{
    I[0] = 0, J[0] = 0, J[1] = 1;
    val[0] = (float)rand()/RAND_MAX + 10.0f;
    val[1] = (float)rand()/RAND_MAX;
    int start;

    for (int i = 1; i < N; i++)
    {
        if (i > 1)
        {
            I[i] = I[i-1]+3;
        }
        else
        {
            I[1] = 2;
        }

        start = (i-1)*3 + 2;
        J[start] = i - 1;
        J[start+1] = i;

        if (i < N-1)
        {
            J[start+2] = i + 1;
        }

        val[start] = val[start-1];
        val[start+1] = (float)rand()/RAND_MAX + 10.0f;

        if (i < N-1)
        {
            val[start+2] = (float)rand()/RAND_MAX;
        }
    }

    I[N] = nz;
}

extern "C" void funcao2(){

	int M = 0, N = 0, nz = 0, *I = NULL, *J = NULL;
	float *val = NULL;
	const float tol = 1e-5f;
	const int max_iter = 10000;
	float *x;
	float *rhs;
	float a, b, na, r0, r1;
	int *d_col, *d_row;
	float *d_val, *d_x, dot;
	float *d_r, *d_p, *d_Ax;
	int k;
	float alpha, beta, alpham1;

	int i,j,iter;
	

	/* Generate a random tridiagonal symmetric matrix in CSR format */
	FILE *arquivo;

        arquivo = fopen("tamanho_matriz","r");

        int tamanho;

        fscanf(arquivo,"%d",&tamanho);

        M = N = tamanho;

	//M = N = 10485760;
	nz = (N-2)*3 + 4;
	I = (int *)malloc(sizeof(int)*(N+1));
	J = (int *)malloc(sizeof(int)*nz);
	val = (float *)malloc(sizeof(float)*nz);
	genTridiag_2(I, J, val, N, nz);

	x = (float *)malloc(sizeof(float)*N);
	rhs = (float *)malloc(sizeof(float)*N);

	for (i = 0; i < N; i++)
	{
		rhs[i] = 1.0;
		x[i] = 0.0;
	}	


	/* Get handle to the CUBLAS context */
	cublasHandle_t cublasHandle = 0;
	cublasStatus_t cublasStatus;
	cublasStatus = cublasCreate(&cublasHandle);

	//checkCudaErrors(cublasStatus);

	/* Get handle to the CUSPARSE context */
	cusparseHandle_t cusparseHandle = 0;
	cusparseStatus_t cusparseStatus;
	cusparseStatus = cusparseCreate(&cusparseHandle);

	//checkCudaErrors(cusparseStatus);

	cusparseMatDescr_t descr = 0;
	cusparseStatus = cusparseCreateMatDescr(&descr);

	//checkCudaErrors(cusparseStatus);

	cusparseSetMatType(descr,CUSPARSE_MATRIX_TYPE_GENERAL);
	cusparseSetMatIndexBase(descr,CUSPARSE_INDEX_BASE_ZERO);

	cudaMalloc((void **)&d_col, nz*sizeof(int));
	cudaMalloc((void **)&d_row, (N+1)*sizeof(int));
	cudaMalloc((void **)&d_val, nz*sizeof(float));
	cudaMalloc((void **)&d_x, N*sizeof(float));
	cudaMalloc((void **)&d_r, N*sizeof(float));
	cudaMalloc((void **)&d_p, N*sizeof(float));
	cudaMalloc((void **)&d_Ax, N*sizeof(float));

	cudaMemcpy(d_col, J, nz*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_row, I, (N+1)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_val, val, nz*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_r, rhs, N*sizeof(float), cudaMemcpyHostToDevice);


	alpha = 1.0;
	alpham1 = -1.0;
	beta = 0.0;
	r0 = 0.;

	float rsum, diff, err;

	for(iter=0;iter<20;iter++){
		receiveMessage("funcao2","funcao1", FLOAT, (void*)d_x, N*N);
		receiveMessage("funcao2","funcao1", INT, (void*)d_col, nz);
		receiveMessage("funcao2","funcao1", INT, (void*)d_row, N+1);
		receiveMessage("funcao2","funcao1", FLOAT, (void*)d_val, nz);


		cusparseScsrmv(cusparseHandle,CUSPARSE_OPERATION_NON_TRANSPOSE, N, N, nz, &alpha, descr, d_val, d_row, d_col, d_x, &beta, d_Ax);

		cublasSaxpy(cublasHandle, N, &alpham1, d_Ax, 1, d_r, 1);
		cublasStatus = cublasSdot(cublasHandle, N, d_r, 1, d_r, 1, &r1);

		k = 1;

		while (r1 > tol*tol && k <= max_iter)
	    	{
			if (k > 1)
	       		{
			    b = r1 / r0;
			    cublasStatus = cublasSscal(cublasHandle, N, &b, d_p, 1);
			    cublasStatus = cublasSaxpy(cublasHandle, N, &alpha, d_r, 1, d_p, 1);
			}
			else
			{
		    		cublasStatus = cublasScopy(cublasHandle, N, d_r, 1, d_p, 1);
			}

			cusparseScsrmv(cusparseHandle, CUSPARSE_OPERATION_NON_TRANSPOSE, N, N, nz, &alpha, descr, d_val, d_row, d_col, d_p, &beta, d_Ax);
			cublasStatus = cublasSdot(cublasHandle, N, d_p, 1, d_Ax, 1, &dot);
			a = r1 / dot;

			cublasStatus = cublasSaxpy(cublasHandle, N, &a, d_p, 1, d_x, 1);
			na = -a;
			cublasStatus = cublasSaxpy(cublasHandle, N, &na, d_Ax, 1, d_r, 1);

			r0 = r1;
			cublasStatus = cublasSdot(cublasHandle, N, d_r, 1, d_r, 1, &r1);
			cudaThreadSynchronize();
			//printf("iteration = %3d, residual = %e\n", k, sqrt(r1));
			k++;
	    	}

		cudaMemcpy(x, d_x, N*sizeof(float), cudaMemcpyDeviceToHost);
		//Send to the next filter
		sendMessage("funcao2","funcao3", FLOAT, (void*)d_x, N*N);
		sendMessage("funcao2","funcao3", INT, (void*)d_col, nz);
		sendMessage("funcao2","funcao3", INT, (void*)d_row, N+1);
		sendMessage("funcao2","funcao3", FLOAT, (void*)d_val, nz);

		rsum = 0.0;
 		diff = 0.0;
		err = 0.0;

		for (i = 0; i < N; i++)
	    	{
			rsum = 0.0;

			for (j = I[i]; j < I[i+1]; j++)
			{
			    rsum += val[j]*x[J[j]];
			}

			diff = fabs(rsum - rhs[i]);

			if (diff > err)
			{
			    err = diff;
			}
	   	}
		//generate the matrix again
		genTridiag_2(I, J, val, N, nz);
		cudaMemcpy(d_col, J, nz*sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_row, I, (N+1)*sizeof(int), cudaMemcpyHostToDevice);
		cudaMemcpy(d_val, val, nz*sizeof(float), cudaMemcpyHostToDevice);
	}

	cusparseDestroy(cusparseHandle);
	cublasDestroy(cublasHandle);

	free(I);
	free(J);
	free(val);
	free(x);
	free(rhs);
	cudaFree(d_col);
	cudaFree(d_row);
	cudaFree(d_val);
	cudaFree(d_x);
	cudaFree(d_r);
	cudaFree(d_p);
	cudaFree(d_Ax);

	
	
	
		



		

}
