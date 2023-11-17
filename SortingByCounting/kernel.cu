
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include<stdlib.h>
__global__ void SortP(long int* a, long int* c)
{
	int pos,data,j,temp;
	int i = threadIdx.x;
	int n = blockDim.x;

		data = a[i]; 
		pos = 0;
		for (j = 0; j < n; j++)
			if (a[j] < data || (a[j] == data && j < i))
				pos++;
		c[pos] = data;

}


int main()
{
	long int* dev_a = 0;
	long int* dev_c = 0;
	long int* a;
	long int* c;
	long int size;
	cudaError_t cudaStatus;
	printf("Enter the size of the array");
	scanf_s("%ld", &size);
	a = (long int*)malloc(sizeof(long int) * size);
	c = (long int*)malloc(sizeof(long int) * size);
	printf("Enter the array");
	for (long int i = 0; i < size; i++)
	{
		scanf_s("%d", &a[i]);
	}
	cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(long int));
	cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(long int));
	cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(long int), cudaMemcpyHostToDevice);

	

		SortP << < 1, size >> > (dev_a,dev_c);
		

	
	cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(long int), cudaMemcpyDeviceToHost);
	printf("Result\n");
	for (long int w = 0; w < size; w++)
	{
		printf("%ld\t", c[w]);
	}
	cudaFree(dev_a);
	cudaFree(dev_c);
	return 0;
}
