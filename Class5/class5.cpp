#include<stdio.h>
#include<mpi.h>
int main(int argc, char** argv)
{
	int rank,n, size, A[25], B[5];
	float C[5];
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	if (rank == 0)
	{
		printf("enter number of elements");
		fflush(stdout);
		scanf_s("%d", &n);

		printf("enter elements");
		fflush(stdout);
		for (int i = 0; i < n; i++)
		{
			scanf_s("%d", &A[i]);
		}
	}
	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Scatter(A, 5, MPI_INT, B, 5, MPI_INT, 0, MPI_COMM_WORLD);
	float avg = 0;
	for (int i = 0; i < 5; i++)
	{
		
		avg += B[i];

	}
	avg /= 5;
	MPI_Gather(&avg, 1, MPI_FLOAT, C, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);
	if (rank == 0)
	{
		avg = 0;
		for(int i=0;i<5;i++)
		avg += C[i];
		printf("Total Average is %f", avg / 5);
	}
	MPI_Finalize();
	return 0;
}