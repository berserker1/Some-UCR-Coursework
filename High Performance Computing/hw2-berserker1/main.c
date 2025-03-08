#include "include.h"
#include "func_call.c"

int main(int argc,char **argv)
{
    if (argc!=3)
    {
        printf("Usage: ./main {func_name} {n}\n");
        exit(0);
    }
    char *func_name=argv[1];
    int n=atoi(argv[2]);
    FILE *pad_file=fopen("pad.txt","r");
    int pad;
    fscanf(pad_file,"%d",&pad);
    fclose(pad_file);
    n=((n+pad-1)/pad)*pad;
    printf("n=%d, pad=%d\n",n,pad);
    double *A_backup=(double*)malloc(n*n*sizeof(double));
    double *AA_backup=(double*)malloc(n*n*sizeof(double));
    double *B_backup=(double*)malloc(n*sizeof(double));
    double *BB_backup=(double*)malloc(n*sizeof(double));
    double *A=(double*)malloc(n*n*sizeof(double));
    double *B=(double*)malloc(n*sizeof(double));

    srand(time(NULL));
    for (int i=0;i<n*n;i++)
    {
        A_backup[i]=((double)rand()/RAND_MAX)*2-1;
        A[i]=A_backup[i];
        AA_backup[i] = A_backup[i];
    }
    for (int i=0;i<n;i++)
    {
        B_backup[i]=((double)rand()/RAND_MAX)*2-1;
        B[i]=B_backup[i];
        BB_backup[i] = B_backup[i];
    }
    // printf("\n A is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", A[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    struct timeval start,end;
    gettimeofday(&start,NULL);
    func_call(func_name,A,B,n);
    gettimeofday(&end,NULL);
    printf("time=%lfs\n",end.tv_sec-start.tv_sec+1e-6*(end.tv_usec-start.tv_usec));
    
    // printf("\n B is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f\n", B[i]);
    // }
    // printf("\n");
    // for (int i=0;i<n;i++)
    // {
    //     double sum=0;
    //     for (int j=0;j<n;j++)
    //         sum+=A_backup[i*n+j]*B[j];
    //     if (fabs(sum-B_backup[i])>1e-5)
    //         printf("Error at row %d: standard=%lf, output=%lf\n",i,B_backup[i],sum);
    //     else
    //         printf("Success %f is value of row %d\n", sum, i);
    // }
    // printf("\n A_backup is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", A_backup[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    // printf("\n B_backup and BB_backup\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f %f\n", B_backup[i], BB_backup[i]);
    // }
    // printf("\n A_backup is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", A_backup[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    // printf("\n AA_backup is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", AA_backup[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    // BB_backup[0] = 5.6;
    // B[0] = 4.899;
    // printf("Now\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f %f\n", B_backup[i], BB_backup[i]);
    // }
    // gettimeofday(&start,NULL);
    // func_call("lapack", AA_backup, BB_backup,n);
    // gettimeofday(&end,NULL);
    // printf("time=%lfs\n",end.tv_sec-start.tv_sec+1e-6*(end.tv_usec-start.tv_usec));
    // printf("\nB_backup and BB_backup is\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f %f\n", B_backup[i], BB_backup[i]);
    // }
    // printf("\n After \n");
    // printf("\n AA_backup is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", AA_backup[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    // printf("\n A_backup is \n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("[   ");
    //     for(int j=0; j<n; j++)
    //     {
    //         printf("  %f  ", A_backup[i*n + j]);
    //     }
    //     printf("]\n");
    // }
    
    // printf("\n BB_backup is\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%f\n", BB_backup[i]);
    // }
    // printf("\n");
    // for (int i=0;i<n;i++)
    // {
    //     double sum=0;
    //     for (int j=0;j<n;j++)
    //         sum+=A_backup[i*n+j]*BB_backup[j];
    //     if (fabs(sum-B_backup[i])>1e-5)
    //         printf("Error at row %d: standard=%lf, output=%lf\n",i,B_backup[i],sum);
    //     else
    //         printf("Success %f is value of row %d\n", sum, i);
    // }
}