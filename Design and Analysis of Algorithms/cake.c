#include<stdio.h>
#include<stdlib.h>
int length = 0;
int lefti = -1;
int righti = -1;
long long int max(long long int a, long long int b)
{
    if(a < b)
    {
        return b;
    }
    return a;
}
long long int min(long long int a, long long int b)
{
    if(a < b)
    {
        return a;
    }
    return b;
}
int give_n(int a[], int i, int n, int visited[], int potential)
{
    int index = i-1;
    int set = 0;
    while(index != i)
    {
        if(index < 0)
        {
            index = n-1;
        }
        if(visited[index] == 0)
        {
            lefti = index;
            set = 1;
            break;
        }
        index--;
    }
    index = i+1;
    while(index !=i)
    {
        if(index >= n)
        {
            index = 0;
        }
        if(visited[index] == 0)
        {
            righti = index;
            set = 1;
            break;
        }
        index++;
    }
    if(set == 0)
    {
        // the only piece left
        lefti = index;
        righti = index;
    }
    // printf("now options are %d and %d and index is %d\n", a[lefti], a[righti], i);
    if((lefti == -1) || (righti == -1))
    {
        exit(1);
    }
    return 0;
}
int main()
{
    int n;
    scanf("%d", &n);
    length = n;
    int a[n];
    int visited[n];
    for(int i=0; i<n; i++)
    {
        scanf("%d", &a[i]);
        visited[i] = 0;
    }
    // for(int i=0; i<n; i++)
    // {
    //     printf("%d ", a[i]);
    // }
    // printf("\n");
    // first try
    // int first_try = 1000000000;
    int current = -1;
    long long int total_cost = 0;
    for(int i=0; i<n; i++)
    {
        long long int cost = 0;
        int current_index = i;
        for(int j=0; j<n; j++)
        {
            visited[j] = 0;
        }
        length = n;
        while(length > 0)
        {
            visited[current_index] = 1;
            // my cost
            cost = cost + a[current_index];
            length--;
            // printf("Eaten value %d at index %d\n", a[current_index], current_index);
            give_n(a, current_index, n, visited, 0);
            if(a[lefti] < a[righti])
            {
                visited[righti] = 1;
                // cost = cost + a[righti];
                length--;
                // printf("taken value %d at index %d\n", a[righti], righti);
                give_n(a, righti, n, visited, 0);
                // current_index = righti;
            }
            else
            {
                visited[lefti] = 1;
                // cost = cost + a[lefti];
                length--;
                // printf("taken value %d at index %d\n", a[lefti], lefti);
                give_n(a, lefti, n, visited, 0);
                // current_index = lefti;
            }
            int one = lefti;
            int two = righti;
            int temp1;
            int temp2;
            if(length == 2)
            {
                cost = cost + max(a[lefti], a[righti]);
                break;
            }
            if(length == 1)
            {
                cost = cost + a[lefti];
                break;
            }
            give_n(a, one, n, visited, 1);
            int first_choice = max(a[lefti], a[righti]);
            if(first_choice == a[lefti])
            {
                temp1 = lefti;
            }
            else
            {
                temp1 = righti;
            }
            give_n(a, two, n, visited, 1);
            int second_choice = max(a[lefti], a[righti]);
            if(second_choice == a[lefti])
            {
                temp2 = lefti;
            }
            else
            {
                temp2 = righti;
            }
            int final_choice = min(first_choice, second_choice);
            // printf("final choice value is %d\n", final_choice);
            if(final_choice == first_choice)
            {
                current_index = lefti;
            }
            else
            {
                current_index = righti;
            }
        }
        // printf("\n\ncost when starting with index %d is %lld\n", i, cost);
        total_cost = max(cost, total_cost);
    }
    printf("%lld\n", total_cost);
    return 0;
}