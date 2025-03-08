#include <stdio.h>

long long int total_inversion = 0;

int merge_i(long long int a[], int start, int end, int mid)
{
    long long int count = 0;
    long long int left_length = start + mid - start + 1;
    long long int right_length = end - (start + mid);
    long long int left[left_length];
    long long int right[right_length];
    long long int i, j;
    for(i=0; i<left_length; i++)
    {
        left[i] = a[start + i];
    }
    for(i=0; i<right_length; i++)
    {
        right[i] = a[i+start+mid+1];
    }
    // printf("Left\n");
    // for(i=0; i<left_length; i++)
    // {
    //     printf("%d ", left[i]);
    // }
    // printf("\nRight\n");
    // for(i=0; i<right_length; i++)
    // {
    //     printf("%d ", right[i]);
    // }
    // printf("\n");
    // merge these 2
    i=0, j=0;
    long long int k=0;
    while((i < left_length) && (j < right_length))
    {
        if(left[i] < right[j])
        {
            a[start + k] = left[i];
            i++;
            total_inversion = total_inversion + count;
        }
        else
        {
            a[start+k] = right[j];
            j++;
            count = count + 1;
        }
        k++;
    }
    while(i<left_length)
    {
        a[start + k] = left[i];
        i++;
        k++;
        total_inversion = total_inversion + count;
    }
    while(j<right_length)
    {
        a[start + k] = right[j];
        j++;
        k++;
    }
    // printf("Array after merging\n");
    // for(i=start; i<=end; i++)
    // {
    //     printf("%d ", a[i]);
    // }
    // printf("\n");
    return 0;
}

int mergesort(long long int a[], long long int start, long long int end)
{
    if(start >= end)
    {
        return a[start];
    }
    long long int mid = (end - start)/2; 
    // printf("\n Now left, right, mid is %d %d %d\n", start, end, mid);
    mergesort(a, start, start + mid);
    mergesort(a, start+mid+1, end);
    merge_i(a, start, end, mid);
    return 0;
}
int main()
{
    long long int n;
    scanf("%lld\n", &n);
    long long int i;
    long long int a[n];
    for(i=0; i<n; i++)
    {
        scanf("%lld", &a[i]);
    }
    // for(i=0; i<n; i++)
    // {
    //     printf("%d ", a[i]);
    // }
    mergesort(a, 0, n-1);
    // for(i=0; i<n; i++)
    // {
    //     printf("%d ", a[i]);
    // }
    printf("%lld", total_inversion);
    return 0;
}