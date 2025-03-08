#include<stdio.h>
#include<stdlib.h>

int output[2000][2000];
int a[2000][2000];
int maxf(int a, int b)
{
    if(a > b)
    {
        return a;
    }
    else
    {
        return b;
    }
}

int maxpathcalc(int r, int c, int i, int j)
{
    if(output[i][j] != -1)
    {
        return output[i][j];
    }
    else
    {
        int maxlength = 1;
        //top
        if(i-1 >= 0)
        {
            if(a[i-1][j] < a[i][j])
            {
                maxlength = maxf(maxlength, 1 + maxpathcalc(r, c, i-1, j));
            }
        }
        if(i+1 < r)
        {
            if(a[i+1][j] < a[i][j])
            {
                maxlength = maxf(maxlength, 1 + maxpathcalc(r, c, i+1, j));
            }
        }
        if(j-1 >= 0)
        {
            if(a[i][j-1] < a[i][j])
            {
                maxlength = maxf(maxlength, 1 + maxpathcalc(r, c, i, j-1));
            }
        }
        if(j+1 < c)
        {
            if(a[i][j+1] < a[i][j])
            {
                maxlength = maxf(maxlength, 1 + maxpathcalc(r, c, i, j+1));
            }
        }
        return maxlength;
    }
}
int maxpath(int r, int c)
{
    int maxp=1;
    //top
    for(int i=0; i<r; i++)
    {
        for(int j=0; j<c; j++)
        {
            output[i][j] = maxpathcalc(r, c, i, j);
            maxp = maxf(maxp, output[i][j]);
        }
    }
    return maxp;
}
int main()
{
    int r,c;
    scanf("%d %d", &r, &c);
    for(int i=0; i<r; i++)
    {
        for(int j=0; j<c; j++)
        {
            scanf("%d", &a[i][j]);
            output[i][j] = -1;
        }
    }
    printf("%d\n", maxpath(r, c));
    // for(int i=0; i<r; i++)
    // {
    //     for(int j=0; j<c; j++)
    //     {
    //         printf("%d ", a[i][j]);
    //     }
    //     printf("\n");
    // }

    return 0;
}