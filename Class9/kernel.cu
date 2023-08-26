
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
__global__ void vecAdd(int* A, int* B, int* C, int n)
{
	int idx = blockDim.x * blockIdx.x + threadIdx.x;
	if (idx < n)
	{
		C[idx] = A[idx] + B[idx];
	}

}
int main()
{
	int h_A[8] = { 1,1,1,1,1,1,1,1 };
	int h_B[8] = { 1,1,1,1,1,1,1,1 };
	int h_C[8];
	int* d_A, * d_B, * d_C;
	cudaMalloc(&d_A, sizeof(int) * 8);
	cudaMalloc(&d_B, sizeof(int) * 8);
	cudaMalloc(&d_C, sizeof(int) * 8);
	cudaMemcpy(d_A, h_A, sizeof(int) * 8, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, sizeof(int) * 8, cudaMemcpyHostToDevice);
	vecAdd << <1, 32 >> > ( d_A,d_B,d_C, 8);
	cudaMemcpy(h_C, d_C, sizeof(int) * 8, cudaMemcpyDeviceToHost);
	for (int i = 0; i < 8; i++)
	{
		printf("%d", h_C[i]);
	}
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	return 0;
}
