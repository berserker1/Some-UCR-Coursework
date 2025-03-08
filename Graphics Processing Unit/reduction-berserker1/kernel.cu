/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#define BLOCK_SIZE 512


__global__ void naiveReduction(float *out, float *in, unsigned size)
{
    /********************************************************************
    Load a segment of the input vector into shared memory
    Traverse the reduction tree
    Write the computed sum to the output vector at the correct index
    ********************************************************************/

    // INSERT KERNEL CODE HERE
    // NAIVE REDUCTION IMPLEMENTATION

    __shared__ float partialsum[2 * BLOCK_SIZE];
    unsigned int tid = threadIdx.x;
    if((blockIdx.x*blockDim.x*2 + tid) < size)
    {
        // if(blockIdx.x == 976)
        // {
        //     printf("%d allocating to partialsum %d blockdim, %d blockidx, %d tid, value %f\n", blockDim.x*blockIdx.x*2 + tid, blockDim.x, blockIdx.x, tid, in[blockDim.x*blockIdx.x*2 + tid]);
        // }
        partialsum[tid] = in[blockDim.x*blockIdx.x*2 + tid];
    }
    if((blockIdx.x*blockDim.x*2 + tid + blockDim.x) < size)
    {
        // if(blockIdx.x == 976)
        // {
        //     printf("%d allocating to partialsum + blockdim, %d blockdim, %d blockidx, %d tid, value %f\n", blockDim.x*blockIdx.x*2 + tid + blockDim.x, blockDim.x, blockIdx.x, tid, in[blockDim.x*blockIdx.x*2+blockDim.x + tid]);
        // }
        partialsum[tid + blockDim.x] = in[tid + blockDim.x*blockIdx.x*2 + blockDim.x];
    }
    __syncthreads();
    unsigned int stride;
    for(stride = 1; stride <= blockDim.x; stride *= 2)
    {
        if(tid % stride == 0)
        {
            if(((2 * tid) + stride) < 2 * BLOCK_SIZE)
            {
                if((2*tid < size) && ((blockDim.x*blockIdx.x*2 + 2*tid + stride) < size))
                {
                    // if(blockIdx.x == 976)
                    // {
                    //     printf("%f 2tid %d and %f 2tid+stride %d, stride %d, corresponding numbers %d %d\n", partialsum[2*tid], 2*tid, partialsum[2*tid + stride], 2*tid + stride, stride, blockDim.x*blockIdx.x*2 + 2*tid, blockDim.x*blockIdx.x*2 + 2*tid + stride);
                    // }
                    partialsum[2*tid] += partialsum[2*tid + stride];
                }
            }
        }
        __syncthreads();
    }
    if(tid == 0)
    {
        out[blockIdx.x] = partialsum[0];
    }
    __syncthreads();

    //
    // thread block 0, it will take numbers from 0 - (2*512-1)  in
    // thread block 1 will take numbers frmo 2*512 4*512-1

}

__global__ void optimizedReduction(float *out, float *in, unsigned size)
{
    /********************************************************************
    Load a segment of the input vector into shared memory
    Traverse the reduction tree
    Write the computed sum to the output vector at the correct index
    ********************************************************************/

    // INSERT KERNEL CODE HERE
    // OPTIMIZED REDUCTION IMPLEMENTATION
    __shared__ float partialsum[2 * BLOCK_SIZE];
    unsigned int tid = threadIdx.x;
    if((blockIdx.x*blockDim.x*2 + tid) < size)
    {
        // if(blockIdx.x == 976)
        // {
        //     printf("%d allocating to partialsum %d blockdim, %d blockidx, %d tid, value %f\n", blockDim.x*blockIdx.x*2 + tid, blockDim.x, blockIdx.x, tid, in[blockDim.x*blockIdx.x*2 + tid]);
        // }
        partialsum[tid] = in[blockDim.x*blockIdx.x*2 + tid];
    }
    if((blockIdx.x*blockDim.x*2 + tid + blockDim.x) < size)
    {
        // if(blockIdx.x == 976)
        // {
        //     printf("%d allocating to partialsum + blockdim, %d blockdim, %d blockidx, %d tid, value %f\n", blockDim.x*blockIdx.x*2 + tid + blockDim.x, blockDim.x, blockIdx.x, tid, in[blockDim.x*blockIdx.x*2+blockDim.x + tid]);
        // }
        partialsum[tid + blockDim.x] = in[tid + blockDim.x*blockIdx.x*2 + blockDim.x];
    }
    __syncthreads();
    unsigned int stride;
    for(stride=blockDim.x; stride>0; stride = stride/2)
    {
        if((tid < stride) && (blockDim.x*blockIdx.x*2 + tid + stride < size))
        {
            partialsum[tid] += partialsum[tid + stride];
        }
        __syncthreads();
    }
    if(tid == 0)
    {
        out[blockIdx.x] = partialsum[0];
    }

}
