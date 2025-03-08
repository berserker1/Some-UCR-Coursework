#include<iostream>
#include<vector>
#include<queue>
#include<tuple>

using namespace std;

class Compare{
    public:
        bool operator()(tuple<int, int> a, tuple<int, int> b)
        {
            if(get<0>(a) > get<0>(b))
            {
                return true;
            }
            else if(get<0>(a) == get<0>(b))
            {
                if(get<1>(a) > get<1>(b))
                {
                    return false;
                }
                return true;
            }
            else
            {
                return false;
            }
        }
};
int main()
{
    int n, m;
    scanf("%d %d", &n, &m);
    vector<int> a;
    for(int i=0; i<n; i++)
    {
        int l;
        scanf("%d", &l);
        a.push_back(l);
    }
    int visited[n];
    for(int i=0; i<n; i++)
    {
        visited[i] = 0;
    }
    int left_visited[n];
    for(int i=0; i<n; i++)
    {
        left_visited[i] = n - i - 1;
    }
    sort(a.begin(), a.end());
    long long int count = 0;
    priority_queue<tuple<int, int>, vector<tuple<int, int>>, Compare> diff;
    for(int i=0; i<n-2; i++)
    {
        long long int value = (a[i+1] - a[i]) * (a[i+1] - a[i]);
        diff.push(make_tuple(value, i));
        // cout << "putting value " << value << " choosing pair " << a[i] << " " << a[i+1] << " " << a[i+2] << endl;
    }
    int i=0;
    while(i < m)
    {
        int left = get<1>(diff.top());
        int middle = left + 1;
        int right = left + 2;
        int top = get<0>(diff.top());
        printf("Popping %d %d %d %d\n", top, a[left], a[middle], a[right]);
        if((visited[left] == 0) && (visited[middle] == 0))
        {
            if(visited[right] == 0)
            {
                cout << "All not visited" << endl;
                cout << "added, now count is " << count << endl;
                count = count + top;
                i++;    
            }
            else
            {
                
            }
            visited[left] = 1;
            visited[middle] = 1;
            cout << "added, now count is " << count << endl;
        }
        else
        {
            cout << "Ignoring " << endl;
        }
        diff.pop();
    }
    printf("%lld\n", count);
    return 0;
}