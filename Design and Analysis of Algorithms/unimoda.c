#include<stdio.h>
#include <stdlib.h>

int max(int a, int b)
{
    if(a < b)
    {
        return b;
    }
    return a;
}

int lis(int leftdp[], int a[], int n)
{
    leftdp[0] = 1;
    for(int i=1; i<n; i++)
    {
        leftdp[i] = 1;
        int new_val = -1;
        for(int j=0; j<i; j++)
        {
            if(a[j] < a[i])
            {
                new_val = max(new_val, leftdp[j]+1);
            }
        }
        leftdp[i] = max(new_val, leftdp[i]);
    }
    int ans = -1;
    for(int i=0; i<n; i++)
    {
        ans = max(leftdp[i], ans);
    }
    // printf("%d\n", ans);
    return ans;
}
int main()
{
    int n;
    scanf("%d", &n);
    int a[n];
    int b[n];
    for(int i=0; i<n; i++)
    {
        scanf("%d", &a[i]);
    }
    for(int i=n-1, j=0; i>-1; i--, j++)
    {
        b[j] = a[i];
    }
    int leftdp[n];
    int ansl = lis(leftdp, a, n);
    int rightdp[n];
    int finalans[n];
    int ansr = lis(rightdp, b, n);
    int ans = -1;
    // for(int i=0; i<n; i++)
    // {
    //     printf("%d ", leftdp[i]);
    // }
    // printf("\n");
    // for(int i=0; i<n; i++)
    // {
    //     printf("%d ", rightdp[i]);
    // }
    // printf("\n");
    for(int i=0; i<n; i++)
    {
        finalans[i] = 1;
        int lvalue = leftdp[i];
        int set = 0;
        if(lvalue == 1)
        {
            lvalue = 0;
            set = 1;
        }
        int rvalue = rightdp[n-1-i];
        if(rvalue == 1)
        {
            rvalue = 0;
            set = 1;
        }
        if(set == 0)
        {
            int total = lvalue + rvalue - 1;
            finalans[i] = max(finalans[i], total);
            // printf("final answer is %d\n", finalans[i]);
        }
        ans = max(ans, finalans[i]);
    }
    printf("%d\n", ans);
    return 0;
}