#include "include.c"
#include "name_check.c"
#include "func_call.c"
#include "math.h"

int main(int argc, char **argv)
{
    if (argc!=4)
    {
        printf("Usage: ./starter -func -n -pad\n");
        exit(0);
    }
    char *func_name=argv[1];
    int n=atoi(argv[2]);
    int pad=atoi(argv[3]);
    n=((n+pad-1)/pad)*pad;
    name_check(func_name);
    printf("n=%d\n",n);
    int i,t;

    double *A_backup=(double*)malloc(n*n*sizeof(double));
    double *B_backup=(double*)malloc(n*n*sizeof(double));
    double *C_backup=(double*)malloc(n*n*sizeof(double));
    double *A=(double*)malloc(n*n*sizeof(double));
    double *B=(double*)malloc(n*n*sizeof(double));
    double *C=(double*)malloc(n*n*sizeof(double));
    srand(time(NULL));
    for (i=0;i<n*n;i++)
    {
        A_backup[i]=((double)rand()/RAND_MAX)*2-1;
        A[i]=A_backup[i];
        B_backup[i]=((double)rand()/RAND_MAX)*2-1;
        B[i]=B_backup[i];
        C_backup[i]=((double)rand()/RAND_MAX)*2-1;
        C[i]=C_backup[i];
    }
    struct timeval start,end;
    gettimeofday(&start,NULL);
    func_call(func_name,C,A,B,n);
    gettimeofday(&end,NULL);
    printf("time=%lfs\n",end.tv_sec-start.tv_sec+1e-6*(end.tv_usec-start.tv_usec));
    for (t=0;t<10;t++)
    {
        int i=rand()%n;
        int j=rand()%n;
        int k;
        double standard=C_backup[i*n+j];
        for (k=0;k<n;k++)
            standard+=A_backup[i*n+k]*B_backup[k*n+j];
        if (fabs(C[i*n+j]-standard)>1e-5)
            printf("Error at (%d,%d): standard=%lf, output=%lf\n",i,j,standard,C[i*n+j]);
    }
}