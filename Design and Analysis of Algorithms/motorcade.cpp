#include<iostream>
#include<vector>

using namespace std;
int main()
{
    long long int W;
    int arrSize;
    float L;
    scanf("%lld %f %d", &W, &L, &arrSize);
    float dp[arrSize];
    vector<pair<long long int, long long int>> arr;
    for(int i=0; i<arrSize; i++)
    {
        long long int a, b;
        scanf("%lld %lld", &a, &b);
        arr.push_back(make_pair(a, b));
    }
    dp[0] = (L / arr[0].second) * 60;
    for(int i=1; i<arrSize; i++)
    {
        float imin = INT_MAX;
        imin = imin + INT_MAX;
        long long int current_sum = 0;
        for(int j=0; ; j++)
        {
            current_sum = current_sum + arr[i-j].first;
            if(current_sum > W)
            {
                break;
            }
            if((i-j) < 0)
            {
                break;
            }
            long long int current_min = INT_MAX;
            current_min = current_min + 200;
            int l;
            for(l=0; l<=j; l++)
            {
                current_min = min(arr[i-l].second, current_min);
                printf("a[i-l] is %lld, current min when i is %d, j is %d, l is %d is %lld\n", arr[i-l].first, i, j, l, current_min);
            }
            float minute_speed = current_min / 60.0;
            cout << "minute speed is " << minute_speed << endl;
            // printf("current min when i is %d and j is %d is %d\n", i, j, current_min);
            if((i - j - 1) < 0)
            {
                imin = min(imin, L / minute_speed);
            }
            else
            {
                imin = min(imin, (L / minute_speed) + dp[i-j-1]);
            }
            printf("\n\nValue till current index %d and j is %d is %f\n", i, j, imin);
        }
        dp[i] = imin;
        printf("new dp till index %d is %f\n\n\n", i, dp[i]);
    }
    printf("%.10f\n", dp[arrSize-1]);
}