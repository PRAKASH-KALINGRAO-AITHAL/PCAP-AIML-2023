#include<stdio.h>
#include<mpi.h>
#include<math.h>
int main(int argc, char** argv)
{
	int rank, size, element[10], returnVal[5];
	MPI_Status status;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	if (rank == 0)
	{
		printf("Enter number of elements");
		fflush(stdout);
		scanf_s("%d", &size);
		for(int i=0;i<size;i++)
		scanf_s("%d", &element[i]);
		MPI_Send(&size, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
		MPI_Send(element, ceil(size / 2), MPI_INT, 1, 1, MPI_COMM_WORLD);
		MPI_Recv(returnVal, 5, MPI_INT, 1, 0, MPI_COMM_WORLD, &status);
		int j = 0;
		for (int i = size / 2; i < size; i++,j++)
		{
			element[i] = returnVal[j];
		}
		for(int i=0;i<size;i++)
		printf("%d\t", element[i]);
	}
	if (rank == 1)
	{
		MPI_Recv(&size, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
		MPI_Recv(returnVal, ceil(size/2), MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
		for(int i=0;i<size/2;i++)
		returnVal[i] *= returnVal[i];
		MPI_Send(returnVal, size/2, MPI_INT, 0, 0, MPI_COMM_WORLD);
	}
	MPI_Finalize();
	return 0;
}