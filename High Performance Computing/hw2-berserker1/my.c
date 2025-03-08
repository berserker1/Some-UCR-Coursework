#ifndef __MY_C__
#define __MY_C__

#include "include.h"

int printmat(double *A, int n)
{
    printf("\n\n");
    int i,j;
    for(i=0; i<n; i++)
    {
        printf("[   ");
        for(j=0; j<n; j++)
        {
            printf("  %f  ", A[i*n + j]);
        }
        printf("]\n");
    }
    printf("\n\n");
    return 0;
}
int mydgetrf(double *A,int *ipiv,int n)
{
    //TODO
    //The return value (an integer) can be 0 or 1
    //If 0, the matrix is irreducible and the result will be ignored
    //If 1, the result is valid
    // n = 3;
    // A[0*3 + 0] = 1;
    // A[0*3 + 1] = 2;
    // A[0*3 + 2] = 3;
    // A[1*3 + 0] = 4;
    // A[1*3 + 1] = 13;
    // A[1*3 + 2] = 18;
    // A[2*3 + 0] = 7;
    // A[2*3 + 1] = 54;
    // A[2*3 + 2] = 78;
    int maxind;
    double maxv = 0;
    double temp;
    // printf("start\n");
    // printmat(A, n);
    for(int i=0; i<=n-2; i++)
    {
        maxind = i;
        // printf("max index %d\n", maxind);
        maxv = fabs(A[i*n + i]);
        for(int t=i+1; t<n; t++)
        {
            if(fabs(A[t*n + i]) > maxv)
            {
                maxind = t;
                maxv = fabs(A[t*n + i]);
            }
        }
        if((maxv - 0) < 1e-5)
        {
            // printf("maxv is %f, returning\n", maxv);
            return 0;
        }
        else
        {
            if(maxind != i)
            {
                //switched values
                temp = ipiv[i];
                ipiv[i] = ipiv[maxind];
                ipiv[maxind] = temp;
                //swapping rows
                for(int l=0; l<n; l++)
                {
                    double tempv = A[i*n + l];
                    A[i*n + l] = A[maxind*n + l];
                    A[maxind*n + l] = tempv;
                }
            }
        }
        for(int j=i+1; j<n; j++)
        {
            A[j*n + i] = A[j*n + i]/A[i*n + i];
        }
        for(int j=i+1; j<n; j++)
        {
            for(int k=i+1; k<n; k++)
            {
                A[j*n + k] = A[j*n + k] - A[j*n + i] * A[i*n + k];
            }
        }
        // printmat(A, n);
    }
    return 1;
}

void mydtrsv(char UPLO,double *A,double *B,int n,int *ipiv, double *y, double *x)
{
    //TODO
    if(UPLO == 'L')
    {
        y[0] = B[ipiv[0]];
        for(int i=1; i<n; i++)
        {
            double sum=0;
            for(int l=0; l<=i-1; l++)
            {
                sum = sum + (y[l] * A[i*n + l]);
            }
            y[i] = B[ipiv[i]] - sum;
        }
    }
    else if(UPLO == 'U')
    {
        x[n-1] = y[n-1]/A[(n-1)*n + n-1];
        for(int i=n-2; i>=0; i--)
        {
            double sum = 0;
            for(int l=i+1; l<n; l++)
            {
                sum = sum + (x[l]*A[i*n + l]);
            }
            x[i] = (y[i] - sum)/A[i*n + i];
        }
    }
}

void my_f(double *A,double *B,int n)
{
    int *ipiv=(int*)malloc(n*sizeof(int));
    for (int i=0;i<n;i++)
        ipiv[i]=i;
    if (mydgetrf(A,ipiv,n)==0) 
    {
        printf("LU factoration failed: coefficient matrix is singular.\n");
        return;
    }
    double *y = (double *)malloc(n * sizeof(double));
    // for(int i=0; i<n; i++)
    // {
    //     y[i] = 0;
    // }
    // printf("Y is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f\n", y[i]);
    // }
    double *x = (double *)malloc(n * sizeof(double));
    mydtrsv('L', A, B, n, ipiv, y, x);
    mydtrsv('U', A, B, n, ipiv, y, x);
    // printf("\n y is after\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f\n", y[i]);
    // }
    for(int i=0; i<n; i++)
    {
        B[i] = x[i];
    }
}

#endif