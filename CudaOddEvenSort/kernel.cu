
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include<stdlib.h>
__global__ void odd(long int* A)
{
	int idx = threadIdx.x;
	int size = blockDim.x;
	if ((idx % 2) != 0 && idx + 1 <= size - 1)
	{

		if (A[idx] > A[idx + 1])
		{
			int temp = A[idx];
			A[idx] = A[idx + 1];
			A[idx + 1] = temp;
		}

	}
}
__global__ void even(long int* A)
{
	int idx = threadIdx.x;
	int size = blockDim.x;
	if ((idx % 2) == 0 && idx <= size - 1)
	{

		if (A[idx] > A[idx + 1])
		{
			int temp = A[idx];
			A[idx] = A[idx + 1];
			A[idx + 1] = temp;
		}
	}
}
int main()
{
	long int* dev_a = 0;
	long int* a;
	long int size;
	cudaError_t cudaStatus;
	printf("Enter the size of the array");
	scanf_s("%ld", &size);
	a = (long int*)malloc(sizeof(long int) * size);
	printf("Enter the array");
	for (int i = 0; i < size; i++)
	{
		scanf("%d", &a[i]);
	}
	cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(long int));
	cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(long int), cudaMemcpyHostToDevice);

	for(int i=0;i<size/2;i++)
	{
		
		odd << < 1, size >> > (dev_a);
		even << <1, size >> > (dev_a);
		
	}
	cudaStatus = cudaMemcpy(a, dev_a, size * sizeof(long int), cudaMemcpyDeviceToHost);
	printf("Result\n");
	for (int w = 0; w < size; w++)
	{
		printf("%d\t", a[w]);
	}
	cudaFree(dev_a);
	return 0;
}


