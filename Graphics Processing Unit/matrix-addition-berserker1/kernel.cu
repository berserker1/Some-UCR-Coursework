#include <stdio.h>

#define TILE_SIZE 16

__global__ void matAdd(int dim, const float *A, const float *B, float* C) {

    /********************************************************************
     *
     * Compute C = A + B
     *   where A is a (dim x dim) matrix
     *   where B is a (dim x dim) matrix
     *   where C is a (dim x dim) matrix
     *
     ********************************************************************/

    /*************************************************************************/
    // INSERT KERNEL CODE HERE
    // printf("%f %f Row 25-0 col 0\n", A_h[250000], B_h[250000]);
    int Row = blockIdx.y * blockDim.y + threadIdx.y;
    int Col = blockIdx.x * blockDim.x + threadIdx.x;
    // printf("C %f A %f B %f\n", C[250000], A[250000], B[250000]);
    if ((Row < dim) && (Col < dim))
    {
        C[Row*dim + Col] = A[Row*dim + Col] + B[Row*dim + Col];
        // if(C[Row*dim + Col] != (A[Row*dim + Col] + B[Row*dim + Col]))
        // {
        //     printf("C %f A %f B %f\n", C[Row*dim + Col], A[Row*dim + Col], B[Row*dim + Col]);
        //     return;    
        // }
        // printf("C %f A %f B %f  Row %d Col %d\n", C[Row*dim + Col], A[Row*dim + Col], B[Row*dim + Col], Row, Col);
    }
    /*************************************************************************/

}

void basicMatAdd(int dim, const float *A, const float *B, float *C)
{
    // Initialize thread block and kernel grid dimensions ---------------------

    const unsigned int BLOCK_SIZE = TILE_SIZE;
	
    /*************************************************************************/
    //INSERT CODE HERE
    const unsigned int grid_size = (dim - 1)/BLOCK_SIZE + 1;
    dim3 dimgrid(grid_size, grid_size, 1);
    dim3 dimblock(BLOCK_SIZE, BLOCK_SIZE, 1);
    // printf("Grid : {%d, %d, %d} blocks. Blocks : {%d, %d, %d} threads.\n", dimgrid.x, dimgrid.y, dimgrid.z, dimblock.x, dimblock.y, dimblock.z);
    // printf("%f %f Row 25-0 col 0\n", A[999], B[999]);
    /*************************************************************************/
	
	// Invoke CUDA kernel -----------------------------------------------------
    matAdd<<<dimgrid, dimblock>>>(dim, A, B, C);
    /*************************************************************************/
    //INSERT CODE HERE
    /*************************************************************************/

}

