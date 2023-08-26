#include<mpi.h>
#include<stdio.h>
int main(int argc, char** argv)
{
	int rank, size, element,Master=0;
	int buffer[BUFSIZ];
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
	MPI_Buffer_attach(buffer, BUFSIZ);
	if (rank == Master)
	{
		scanf_s("%d", &element);
		MPI_Bsend(&element, 1, MPI_INT, rank+1, 0, MPI_COMM_WORLD);
		printf("%d\n", element);
		fflush(stdout);
	}
	 if (rank != Master && rank != size - 1)
	{
		MPI_Recv(&element, 1, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		element++;
		printf("%d\n", element);
		fflush(stdout);
		MPI_Bsend(&element, 1, MPI_INT, rank + 1, 0, MPI_COMM_WORLD);

	}
	 if (rank == size - 1)
	 {
		 MPI_Recv(&element, 1, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		 element++;
		 printf("%d\n", element);
		 fflush(stdout);
	 }
	 int bufsize = BUFSIZ;
	 MPI_Buffer_detach(&buffer, &bufsize);
	 MPI_Finalize();
	 return 0;
}