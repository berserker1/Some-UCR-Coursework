#include <stdio.h>

#define TILE_SIZE 16

__global__ void mysgemm(int m, int n, int k, const float *A, const float *B, float* C) {

    /********************************************************************
     *
     * Compute C = A x B
     *   where A is a (m x k) matrix
     *   where B is a (k x n) matrix
     *   where C is a (m x n) matrix
     *
     * Use shared memory for tiling
     *
     ********************************************************************/

    /*************************************************************************/
    // INSERT KERNEL CODE HERE
        
    /*************************************************************************/
    __shared__ float tilea[TILE_SIZE*TILE_SIZE];
    __shared__ float tileb[TILE_SIZE*TILE_SIZE];
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    float pvalue = 0;

    for(int p=0; p<((k-1)/TILE_SIZE + 1); p++)
    {
        if((row < m) && ((p*TILE_SIZE + threadIdx.x) < k))
        {
            tilea[threadIdx.y*TILE_SIZE+threadIdx.x] = A[row*k + p*TILE_SIZE+threadIdx.x];
        }
        else
        {
            tilea[threadIdx.y*TILE_SIZE+threadIdx.x] = 0;
        }
        if((col < n) && ((p*TILE_SIZE + threadIdx.y) < k))
        {
            tileb[threadIdx.y*TILE_SIZE+threadIdx.x] = B[col + (p*TILE_SIZE+threadIdx.y)*n];
        }
        else
        {
            tileb[threadIdx.y*TILE_SIZE+threadIdx.x] = 0;
        }
        __syncthreads();
        if((row < m) && (col < n))
        {
            for(int l=0; l<TILE_SIZE; l++)
            {
                pvalue = pvalue + tilea[threadIdx.y * TILE_SIZE + l] * tileb[l * TILE_SIZE + threadIdx.x];
            }
        }
        __syncthreads();
    }
    if ((row < m) && (col < n))
    {
        C[row*n+col] = pvalue;
    }
}

void basicSgemm(int m, int n, int k, const float *A, const float *B, float *C)
{
    // Initialize thread block and kernel grid dimensions ---------------------

    const unsigned int BLOCK_SIZE = TILE_SIZE;
	
    /*************************************************************************/
    //INSERT CODE HERE

    /*************************************************************************/

    // Invoke CUDA kernel -----------------------------------------------------

    /*************************************************************************/
    //INSERT CODE HERE
	
    /*************************************************************************/
    dim3 DimGrid( (n - 1) / BLOCK_SIZE + 1, (m - 1) / BLOCK_SIZE + 1, 1);
    dim3 DimBlock(BLOCK_SIZE,BLOCK_SIZE,1);
    mysgemm<<<DimGrid,DimBlock>>>(m, n, k, A, B, C);
}


