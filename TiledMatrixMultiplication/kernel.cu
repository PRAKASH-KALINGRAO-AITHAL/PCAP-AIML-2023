
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#define ha 8
#define wa 8
#define hb 8
#define wb 8
#define hc 8
#define wc 8
#define TILE_WIDTH 2
__global__ void multiplyKernel_elementwise(int* a, int* b, int* c)
{
	__shared__ float Mds[TILE_WIDTH][TILE_WIDTH];
	__shared__ float Nds[TILE_WIDTH][TILE_WIDTH];
	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	int Col = bx * TILE_WIDTH + tx;
	int Row = by * TILE_WIDTH + ty;
	int Pvalue = 0;
	for (int bloc = 0; bloc < (wc / TILE_WIDTH); ++bloc)
	{
		Mds[ty][tx] = a[Row * wc + bloc * TILE_WIDTH + tx];
		Nds[ty][tx] = b[(bloc * TILE_WIDTH + ty) * wc + Col];

		__syncthreads();
		for (int k = 0; k < TILE_WIDTH; ++k)
		{
			Pvalue += Mds[ty][k] * Nds[k][tx];
		}
		__syncthreads();
	}
	c[Row * wc + Col] = Pvalue;

}



int main()
{
	int h_A[ha][wa] = { {1,2,3,1,1,2,3,1},{1,1,1,1,1,2,3,1},{1,2,2,1,1,2,3,1},{1,0,3,1,1,2,3,1},{1,2,3,1,1,2,3,1},{1,1,1,1,1,2,3,1},{1,2,2,1,1,2,3,1},{1,0,3,1,1,2,3,1} };
	int h_B[hb][wb] = { {1,2,3,4,1,2,3,1},{1,1,1,1,1,2,3,1},{1,2,3,2,1,2,3,1} ,{1,1,1,1,1,2,3,1},{1,2,3,1,1,2,3,1},{1,1,1,1,1,2,3,1},{1,2,2,1,1,2,3,1},{1,0,3,1,1,2,3,1} };
	int h_C[hc][wc];
	int* d_A, * d_B, * d_C;
	cudaMalloc(&d_A, sizeof(int) * ha * wa);
	cudaMalloc(&d_B, sizeof(int) * hb * wb);
	cudaMalloc(&d_C, sizeof(int) * hc * wc);
	cudaMemcpy(d_A, h_A, sizeof(int) * ha * wa, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, sizeof(int) * hb * wb, cudaMemcpyHostToDevice);
	dim3 GridDimension(wc / TILE_WIDTH, hc / TILE_WIDTH, 1);
	dim3 BlockDimension(TILE_WIDTH, TILE_WIDTH, 1);
	multiplyKernel_elementwise << < GridDimension, BlockDimension >> > (d_A, d_B, d_C);

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