#include<iostream>
#include<vector>
using namespace std;

typedef pair<long long int, long long int> pi;
bool comparison(const pi a, const pi b)
{
    return a.second < b.second;
}
int main()
{
    long long int n;
    long long int count = 0;
    scanf("%lld", &n);
    vector<pi> a;
    vector<pi> new_a;
    long long int index[n];
    vector<pi> first;
    vector<pi> second;
    for(long long int i=0; i<n; i++)
    {
        long long int start, end;
        scanf("%lld %lld", &start, &end);
        pi p = make_pair(start, end);
        a.push_back(p);
        index[i] = 0;
    }
    sort(a.begin(), a.end(), comparison);
    // cout << "After sorting " << endl;
    // for(long long int i=0; i<n; i++)
    // {
    //     cout << a[i].first << " " << a[i].second << endl;
    // }
    first.push_back(a[0]);
    // cout << "Now solving" << endl;
    long long int first_min = a[0].second;
    long long int second_min = -1;
    long long int first_conflict = 0;
    for(long long int i=1; i<a.size(); i++)
    {
        // cout << "current " << a[i].first << " " << a[i].second << endl;
        if((a[i].first - first_min) >= 1)
        {
            long long int value = a[i].first - first_min;
            if(first_conflict == 1)
            {
                long long int second_value = a[i].first - second_min;
                if((second_value < value) && (second_value >= 1))
                {
                    second.push_back(a[i]);
                    second_min = a[i].second;
                    // cout << "Added in second queue value " << a[i].first << " " << a[i].second << endl;
                }
                else
                {
                    first.push_back(a[i]);
                    first_min = a[i].second;
                    // cout << "Added in first queue value " << a[i].first << " " << a[i].second << endl;
                }
            }
            else
            {
                first.push_back(a[i]);
                first_min = a[i].second;
                // cout << "Added in first queue " << a[i].first << " " << a[i].second << endl;
            }
        }
        else
        {
            if(second_min == -1)
            {
                second.push_back(a[i]);
                second_min = a[i].second;
                // cout << "First conflict " << a[i].first << " " << a[i].second << endl;
                first_conflict = 1;
            }
            else
            {
                if((a[i].first - second_min) >= 1)
                {
                    second.push_back(a[i]);
                    second_min = a[i].second;
                    // cout << "Added in second queue " << a[i].first << " " << a[i].second << endl;
                }
            }
        }
    }
    cout << first.size() + second.size() << endl;
    return 0;
}