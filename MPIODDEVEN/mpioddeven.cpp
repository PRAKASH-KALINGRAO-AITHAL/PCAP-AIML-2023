#include<stdio.h>
#include<mpi.h>

int computePartner(int phase, int rank,int size)
{
	int partner;
	if (phase % 2 == 0)
	{
		if (rank % 2 != 0)
		{
			partner = rank - 1;
		}
		else
		{
			partner = rank + 1;
		}
	}
	else if (rank % 2 != 0)
	{
		partner = rank + 1;
	}
	else
	{
		partner = rank - 1;
	}
	if (partner == -1 || partner == size)
	{
		partner = MPI_PROC_NULL;
	}
	return partner;
}
int main(int argc, char** argv)
{
	int rank, size, A[8], n, a,b;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	if (rank == 0)
	{
		printf("Enter number of elements");
		fflush(stdout);
		scanf_s("%d", &n);
		for (int i = 0; i < n; i++)
			scanf_s("%d", &A[i]);
	}
	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
	MPI_Scatter(A, 1, MPI_INT, &a, 1, MPI_INT, 0, MPI_COMM_WORLD);
	b = a;
	for (int i = 0; i < size; i++)
	{
		int partner = computePartner(i, rank, size);
		MPI_Sendrecv(&a, 1, MPI_INT, partner, 0, &b, 1, MPI_INT, partner, 0, MPI_COMM_WORLD, MPI_STATUSES_IGNORE);
			if (rank < partner)
			{
				if (a > b)
				{
					a = b;
				}
				
			}
			else if(rank>partner)
			{
				if (a < b)
				{
					a = b;
				}
				
			}
	
		if (partner)
		{
			MPI_Sendrecv(&a, 1, MPI_INT, rank, 0, &b, 1, MPI_INT, rank, 0, MPI_COMM_WORLD, MPI_STATUSES_IGNORE);
		}
	
		
	}
	MPI_Gather(&a, 1, MPI_INT, A, 1, MPI_INT, 0, MPI_COMM_WORLD);
	if (rank == 0)
	{
		printf("Sorted Array is");
		fflush(stdout);
		for (int i = 0; i < n; i++)
		{
			printf("%d\t", A[i]);
		}
	}
	MPI_Finalize();
	return 0;
}