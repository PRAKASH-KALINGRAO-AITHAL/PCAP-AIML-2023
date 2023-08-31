
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

__global__ void convolution_global_memory(float *N, float *M, float *P, int Width,int MASK_WIDTH) {

	int i = blockIdx.x * blockDim.x + threadIdx.x;

	float Pvalue = 0;

	int n_start_point = i - (MASK_WIDTH / 2);

	for (int j = 0; j < MASK_WIDTH; j++) {
		if (n_start_point + j >= 0 && n_start_point + j < Width) {
			Pvalue += N[n_start_point + j] * M[j];
		}
	}

	P[i] = Pvalue;
	
}
int main()
{
	float *h_N, *h_M, *h_P;
	float *d_N, *d_M, *d_P;
	int N, M;
	cudaError_t cudaStatus;
	printf("Enter the Array Size");
	scanf_s("%d", &N);
	
	printf("Enter the Mask Size");
	scanf_s("%d", &M);
	
	h_N = (float*)malloc(sizeof(float) * N);
	printf("Enter the Array");
	for (int k = 0; k < N; k++)
	{
		scanf("%f",&h_N[k]);
	}
	h_P = (float*)malloc(sizeof(float) * N);
	h_M = (float*)malloc(sizeof(float) * M);
	printf("Enter the Mask");
	for (int k = 0; k < M; k++)
	{
		scanf("%f",&h_M[k]);
	}
	cudaStatus=cudaMalloc((void**)&d_N, sizeof(float) * N);
	printf("%d", cudaStatus);
	cudaStatus=cudaMalloc((void**)&d_P, sizeof(float) * N);
	printf("%d", cudaStatus);
	cudaStatus=cudaMalloc((void**)&d_M, sizeof(float) * M);
	printf("%d", cudaStatus);
	cudaStatus=cudaMemcpy(d_N, h_N, N * sizeof(float), cudaMemcpyHostToDevice);
	printf("%d", cudaStatus);
	cudaStatus=cudaMemcpy(d_M, h_M, M * sizeof(float), cudaMemcpyHostToDevice);
	printf("%d\n", cudaStatus);
	convolution_global_memory <<< 1, N >>>(d_N, d_M, d_P, N, M);
	cudaStatus=cudaMemcpy(h_P, d_P, N * sizeof(float), cudaMemcpyDeviceToHost);
	printf("%d", cudaStatus);
	printf("\nResult is\n");
		for (int k = 0; k < N; k++)
		{
			printf("%f\t", h_P[k]);
		}
	cudaFree(d_N);
	cudaFree(d_M);
	cudaFree(d_P);
	return 0;
}
