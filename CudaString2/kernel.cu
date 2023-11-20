
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

__global__ void E7(char* A, char* C)
{
	int idx = threadIdx.x;
	int size = blockDim.x;
	int i = 0;
	while (i <= idx)
	{
		C[i + (idx * (idx + 1) / 2)] = A[idx];
		i++;

	}
}
int main()
{
	char h_A[5] = "PCAP";

	char h_C[11];
	char* d_A, * d_C;
	cudaMalloc(&d_A, sizeof(char) * 5);

	cudaMalloc(&d_C, sizeof(char) * 11);
	cudaMemcpy(d_A, h_A, sizeof(char) * 5, cudaMemcpyHostToDevice);

	E7 << <1, 4 >> > (d_A, d_C);
	cudaMemcpy(h_C, d_C, sizeof(char) * 11, cudaMemcpyDeviceToHost);
	for (int i = 0; i < 11; i++)
	{
		printf("%c", h_C[i]);
	}
	cudaFree(d_A);

	cudaFree(d_C);
	return 0;
}