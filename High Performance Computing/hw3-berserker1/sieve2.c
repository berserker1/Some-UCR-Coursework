#ifndef __SIEVE2_C__
#define __SIEVE2_C__

#include "include.h"

void sieve2(unsigned long long *global_count,unsigned long long n,int pnum,int pid)
{
    unsigned long long low_value=2+pid*(n-1)/pnum;//the smallest value handled by this process
    if(low_value % 2 == 0)
    {
        low_value = low_value + 1;
    }
    unsigned long long high_value=1+(pid+1)*(n-1)/pnum;//the largest value handled by this process
    if(high_value % 2 == 0)
    {
        // if(high_value == n)
        // {
        //     high_value = high_value - 1;
        // }
        // else
        // {
        //     high_value = high_value + 1;
        // }
        high_value = high_value - 1;
    }
    unsigned long long size=(high_value-low_value+1)/2 + 1;//number of integers handled by this process
    unsigned long long osize = high_value - low_value + 1;
    unsigned long long a = (int)sqrt((double)n);
    unsigned long long prime_size;
    if(a%2 == 0)
    {
        prime_size = a/2;
    }
    else
    {
        prime_size = a/2 + 1;
    }
    // printf("low val %d high val %d pid is %d size is %d\n", low_value, high_value, pid, size);
    if (1+(n-1)/pnum<(int)sqrt((double)n))//high_value of process 0 should be larger than floor(sqrt(n))
    {
        if (pid==0)
            printf("Error: Too many processes.\n");
        MPI_Finalize();
        exit(0);
    }
    char *marked=(char*)malloc(size);//array for marking multiples. 1 means multiple and 0 means prime
    char *primes=(char*)malloc((int)sqrt((double)n));
    if (marked==NULL)
    {
        printf("Error: Cannot allocate enough memory.\n");
        MPI_Finalize();
        exit(0);
    }
    memset(marked,0,size);
    memset(primes, 0, prime_size);
    unsigned long long index=0;//index of current prime among all primes (only works for process 0)
    unsigned long long new_index;
    unsigned long long prime=3;//current prime broadcasted by process 0
    do
    {
        unsigned long long first;//index of the first multiple among values handled by this process
        unsigned long long original;
        if(prime * prime <= a)
        {
            for(unsigned long long i=prime*prime; i<=a; i = i + 2*prime)
            {
                primes[i/2] = 1;
                // printf("marked at index of primes %d, value is %d, id is %d\n", i/2, i, pid);
            }
        }
        if(prime * prime > low_value)
        {
            first = (prime * prime - low_value)/2;
            original = (prime * prime - low_value);
        }
        else
        {
            if(low_value % prime == 0)
            {
                first = 0;
                original = 0;
            }
            else
            {
                first = prime - low_value%prime;
                if(((low_value + first) * prime) % 2 == 0)
                {
                    first = first + prime;
                }
                original = first;
            }
        }
        // printf("original index is %d, osize is %d, prime is %d, pid is %d\n", original, osize, prime, pid);
        for(unsigned long long i=original; i<osize; i = i + 2*prime)
        {
            // primes[i/2] = 1;
            marked[i/2] = 1;
            // printf("marked at index %d, value is %d, id is %d\n", i/2, low_value + i, pid);
            // printf("marked at index of primes %d, value is %d, id is %d\n", i/2, i+1, pid);
        }
        index++;
        if(index >= prime_size)
        {
            // printf("index is %d, greater than %d\n", index, prime_size);
            new_index = index - prime_size;
            while(marked[new_index] == 1)
            {
                new_index++;
                index++;
            }
            prime = 2*new_index + 3;
        }
        else
        {
            new_index = index;
            while(primes[new_index] == 1)
            {
                // if(new_index % 2 == 0)
                // {
                //     //pass
                // }
                // else if(primes[new_index] == 1)
                // {
                //     //pass
                // }
                // else if(primes[new_index] == 0)
                // {
                //     break;
                // }
                new_index++;
                index++;
            }
            prime = 2*new_index + 1;
        }
        // printf("next prime %d, pid is %d\n", prime, pid);
        // if(pid == 0)
        // {
        //     while(marked[index] == 1)
        //     {
        //         index++;
        //     }
        //     prime = 2*index + 3;
        //     printf("next prime %d, pid is %d\n", prime, pid);
        // }
    } while (prime * prime <= n);
    unsigned long long count=0;//local count of primes
    for (unsigned long long i=0;i<size;i++)
        if (marked[i]==0)
            count++;
    MPI_Reduce(&count,global_count,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
    *global_count = *global_count + 1;
}

#endif