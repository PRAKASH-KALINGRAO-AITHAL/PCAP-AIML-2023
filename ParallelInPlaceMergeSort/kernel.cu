#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include<stdlib.h>
#include<math.h>
__global__ void CompareExchange(long int* A, int pass)
{
	int idx = threadIdx.x;
	if (idx <= pass)
	{
		int i = idx * 2 * pass;
		int j = idx * 2 * pass + pass;
		int flag = 0;
		int z = 0;

		for (int k = 0; k <= pass; k += 1)
		{
			

			flag = 0;
			for (z = 0; z < pass; z += 1)
			{
				
				if (A[i + k] >= A[j + z])
				{
					int temp = A[i + k];
					A[i + k] = A[j + z];
					A[j + z] = temp;
					flag++;
					k++;
				}
				if (A[i + k] < A[j + z])
				{
					flag++;
					k++;
				}

			}

			while (flag > 0)
			{
				k--;
				flag--;
			}

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

    long int N = size / 2;
	long int i = 1;
	while (N >= 1)
	{
		cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(long int));
		cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(long int), cudaMemcpyHostToDevice);
		CompareExchange <<< 1,N  >> > (dev_a, i);
		cudaStatus = cudaMemcpy(a, dev_a, size * sizeof(long int), cudaMemcpyDeviceToHost);
		i = i * 2;
		N = N / 2;
	}
    printf("Result\n");
    for (int w = 0; w < size; w++)
    {
        printf("%d\t",a[w]);
    }
    cudaFree(dev_a);
    return 0;
}


