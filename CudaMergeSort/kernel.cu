
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include<stdlib.h>

__device__ int co_rank(long int k, long int* A, long int m, long int* B, long int n)
{
	int i = k < m ? k : m;
	int j = k - i;
	int i_low = 0 > (k - n) ? 0 : (k - n);
	int j_low = 0 > (k - m) ? 0 : (k - m);
	int delta;
	bool active = true;
	while (active)
	{
		if (i > 0 && j<n && A[i - 1]>B[j])
		{
			delta = ((i - i_low+1)>>1);
			j_low = j;
			j = j + delta;
			i = i - delta;
		}
		else if (j > 0 && i < m && B[j - 1] >= A[i])
		{
			delta = ((j - j_low+1)>>2);
			i_low = i;
			j = j - delta;
			i = i + delta;

		}
		else
			active = false;
	}
	return i;
}
__device__ void merge_sequential(long int* A, long int m, long int* B,long int n, long int* C)
{
	int i = 0;
	int j = 0;
	int k = 0;
	while ((i < m) && (j < n))
	{
		if (A[i] <= B[j])
		{
			C[k++] = A[i++];
		}
		else
		{
			C[k++] = B[j++];
		}
	}
	if (i == m)
	{
		for (; j < n; j++)
			C[k++] = B[j];
	}
	else
	{
		for (; i < m; i++)
			C[k++] = A[i];
	}
}
__global__ void merge_basic(long int* A,long int m, long int *B, long int n, long int *C)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int k_current = idx * ((m + n)+ (blockDim.x * gridDim.x )/ (blockDim.x * gridDim.x));
	int k_next = (idx + 1) * (((m + n) + (blockDim.x * gridDim.x)) / (blockDim.x * gridDim.x)) < (m + n)?  ((m + n) + (blockDim.x * gridDim.x) / (blockDim.x * gridDim.x )):(m+n);
	int i_current = co_rank(k_current, A, m, B, n);
	int i_next = co_rank(k_next, A, m, B, n);
	int j_current = k_current - i_current;
	int j_next = k_next - i_next;
	merge_sequential(&A[i_current], i_next - i_current, &B[j_current], j_next - j_current, &C[k_current]);
}

int main()
{
	long int* dev_a = 0;
	long int* dev_b = 0;
	long int* dev_c = 0;
	long int* a, *b, *c;
	long int size, size2;
	cudaError_t cudaStatus;
	printf("Enter the size of the first array");
	scanf_s("%ld", &size);
	a = (long int*)malloc(sizeof(long int) * size);
	printf("Enter the array");
	for (long int i = 0; i < size; i++)
	{
		scanf_s("%ld",&a[i]);
	}
	printf("Enter the size of the second array");
	scanf_s("%ld", &size2);
	b = (long int*)malloc(sizeof(long int) * size2);
	printf("Enter the array");
	for (long int i = 0; i < size2; i++)
	{
		scanf_s("%ld", &b[i]);
	}
	c = (long int*)malloc(sizeof(long int) * (size+size2));
	cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(long int));
	cudaStatus = cudaMalloc((void**)&dev_b, size2 * sizeof(long int));
	cudaStatus = cudaMalloc((void**)&dev_c, (size+size2) * sizeof(long int));
	cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(long int), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(dev_b, b, size2 * sizeof(long int), cudaMemcpyHostToDevice);

	

		merge_basic << < 1, 3 >> > (dev_a,size,dev_b,size2,dev_c);
		

	
	cudaStatus = cudaMemcpy(c, dev_c, (size+size2) * sizeof(long int), cudaMemcpyDeviceToHost);
	printf("Result\n");
	for (long int w = 0; w < (size+size2); w++)
	{
		printf("%ld\t", c[w]);
	}
	cudaFree(dev_a);
	return 0;
}


