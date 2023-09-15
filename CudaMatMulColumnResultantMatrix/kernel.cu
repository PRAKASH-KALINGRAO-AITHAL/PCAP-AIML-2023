
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#define ha 5
#define wa 4
#define hb 4
#define wb 5
#define hc 5
#define wc 5
__global__ void multiplyKernel_colwise(int* a, int* b, int* c)
{
	int cidB = threadIdx.x;
	int sum, k;
	for (int ridA = 0; ridA < ha; ridA++)
	{
		sum = 0;
		for (k = 0; k < wa; k++)
		{
			sum += (a[ridA * wa + k] * b[k * wb + cidB]);
		}
		c[ridA * wb + cidB] = sum;
	}
}



int main()
{
	int h_A[ha][wa] = { {1,2,3,1},{1,1,1,1},{1,2,2,1},{1,0,3,1},{2,2,2,1} };
	int h_B[hb][wb] = { {1,2,3,4,5},{1,1,1,1,1},{1,2,3,2,1} ,{1,1,1,1,1} };
	int h_C[hc][wc];
	int* d_A, * d_B, * d_C;
	cudaMalloc(&d_A, sizeof(int) * ha * wa);
	cudaMalloc(&d_B, sizeof(int) * hb * wb);
	cudaMalloc(&d_C, sizeof(int) * hc * wc);
	cudaMemcpy(d_A, h_A, sizeof(int) * ha * wa, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, sizeof(int) * hb * wb, cudaMemcpyHostToDevice);
	multiplyKernel_colwise << <1, wc >> > (d_A, d_B, d_C);

	cudaMemcpy(h_C, d_C, sizeof(int) * hc * wc, cudaMemcpyDeviceToHost);
	for (int i = 0; i < hc; i++)
	{
		for (int j = 0; j < wc; j++)
		{
			printf("%d\t", h_C[i][j]);
		}
		printf("\n");
	}
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	return 0;
}