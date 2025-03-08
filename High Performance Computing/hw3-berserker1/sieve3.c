#ifndef __SIEVE3_C__
#define __SIEVE3_C__

#include "include.h"

void sieve3(unsigned long long *global_count,unsigned long long n,int pnum,int pid)
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
    unsigned long long index=1;//index of current prime among all primes (only works for process 0)
    unsigned long long new_index;
    unsigned long long prime=3;//current prime broadcasted by process 0
    unsigned long long first;//index of the first multiple among values handled by this process
    unsigned long long original;
    do
    {
        // printf("%d is a\n", a);
        /* code */
        for(unsigned long long i=prime*prime; i<=a; i = i + 2*prime)
        {
            primes[i/2] = 1;
            // printf("marked at index of primes %d, value is %d, id is %d\n", i/2, i, pid);
        }
        // if(prime * prime > low_value)
        // {
        //     first = (prime * prime - low_value)/2;
        //     original = (prime * prime - low_value);
        // }
        // else
        // {
        //     if(low_value % prime == 0)
        //     {
        //         first = 0;
        //         original = 0;
        //     }
        //     else
        //     {
        //         first = prime - low_value%prime;
        //         if(((low_value + first) * prime) % 2 == 0)
        //         {
        //             first = first + prime;
        //         }
        //         original = first;
        //     }
            
        // }
        index++;
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
        // printf("next prime %d for pid %d\n", prime, pid);
    } while (prime * prime <= a);
    
    // printf("original index is %d, osize is %d, prime is %d, pid is %d\n", original, osize, prime, pid);
    // printf("low value is %d, high value is %d, pid is %d\n", low_value, high_value, pid);
    for(unsigned long long elem = low_value; elem<=high_value; elem = elem+2)
    {
        if(elem > a)
        {
            unsigned long long ind = (elem - low_value)/2;
            // printf("now checking if elem %d is prime or not, pid is %d\n", elem, pid);
            for(unsigned long long b = 1; b<prime_size; b++)
            {
                unsigned long long val = 2*b + 1;
                if(val * val > elem)
                {
                    break;
                }
                if(primes[b] == 0)
                {
                    if(elem % (val) == 0)
                    {
                        if(elem != (val))
                        {
                            // printf("%d is marked by prime %d at index %d\n", elem, (val), ind);
                            marked[ind] = 1;
                            break;
                        }
                    }
                }
            }
            if(marked[ind] == 0)
            {
                // printf("%d is prime\n", elem);
            }   
        }
    }
    unsigned long long count=0;//local count of primes
    for (unsigned long long i=0;i<size;i++)
    {
        if (marked[i]==0)
        {
            unsigned long long val = 2*i + low_value;
            if(primes[val/2] != 1)
            {
                // printf("counted marked %d, val is %d\n", i, val);
                count++;
            }
        }
    }
    MPI_Reduce(&count,global_count,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
    // if(pid == 0)
    // {
    //     printf("global count is %d\n", *global_count);
    //     for(unsigned long long i=1; i<prime_size; i++)
    //     {
    //         if(primes[i] == 0)
    //         {
    //             printf("counting value at index %d, value is %d\n", i, 2*i+1);
    //             *global_count = *global_count + 1;
    //         }
    //     }
    //     *global_count = *global_count + 1;
    // }
    *global_count = *global_count + 1;
    
}

#endif