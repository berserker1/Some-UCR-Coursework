#include<iostream>
#include<vector>
#include<unordered_map>

using namespace std;

struct sort_pred{
    const bool operator()(const pair<int, int> &left, const pair<int, int> &right)
    {
        int ll;
        int lr;
        if(left.first == left.second)
        {
            ll = 2;
        }
        else
        {
            ll = left.second + 1 - left.first + 1;
        }
        if(right.first == right.second)
        {
            lr = 2;
        }
        else
        {
            lr = right.second + 1 - right.first + 1;
        }
        return ll > lr;
    }
};
int main()
{
    int n;
    scanf("%d", &n);
    int a[n];
    for(int i=0; i<n; i++)
    {
        scanf("%d", &a[i]);
    }
    if(n == 1)
    {
        cout << 1 << endl;
        return 0;
    }
    unordered_map<int, vector<pair<int, int>>> values;
    int count = -260;
    for(int i=0; i<520; i++)
    {
        vector<pair<int, int>> a;
        values.insert({count, a});
        count++;
    }
    int diff[n-1];
    for(int i=0; i<n-1; i++)
    {
        diff[i] = a[i+1] - a[i];
    }
    int same = 1;
    int start = 0;
    int end = 0;
    if(n-1 == 1)
    {
        values[diff[0]].push_back(make_pair(start, end));
    }
    for(int i=1; i<n-1; i++)
    {
        // cout << "now value is " << diff[i] << endl;
        if(diff[i] != diff[i-1])
        {
            same = 0;
            // cout << "now pushing " << start << " " << end << endl;
            values[diff[i-1]].push_back(make_pair(start, end));
            start = i;
            end = i;
            if(i == n-2)
            {
                values[diff[i]].push_back(make_pair(start, end));
                // cout << "now pushing " << start << " " << end << endl;
            }
        }
        else
        {
            same = 1;
            end = i;
            // cout << "Now end increased, hence values are " << start << " " << end << endl;
            if(i == n-2)
            {
                values[diff[i-1]].push_back(make_pair(start, end));
                // cout << "now pushing " << start << " " << end << endl;
            }
        }
    }
    // for(auto const& [key, val]: values)
    // {
    //     if(val.size() != 0)
    //     {
    //         cout << "Key is " << key << endl;
    //         cout << "Values are " << endl;
    //         for(auto &it : val)
    //         {
    //             cout << it.first << " " << it.second << endl;
    //         }
    //         cout << endl;
    //     }
    // }
    int max_count = 0;
    for(auto & [key, val]: values)
    {
        if(val.size() != 0)
        {
            int count_temp = 0;
            int acount = 0;
            sort(val.begin(), val.end(), sort_pred());
            if(val[0].first == val[0].second)
            {
                count_temp = 2;
            }
            else
            {
                count_temp = val[0].second + 1 - val[0].first + 1;
            }
            for(auto &it: val)
            {
                int length;
                if(it.first == it.second)
                {
                    length = 2;
                }
                else
                {
                    length = it.second + 1 - it.first + 1;
                }
                if(length == count_temp)
                {
                    acount++;
                }
            }
            if(acount == 1)
            {
                int answer = 0;
                if((count_temp != 2) && (val.size() != 1))
                {
                    cout << "For subarray of length " << count_temp << " checking others" << endl;
                    int length;
                    if(val[1].first == val[1].second)
                    {
                        length = 2;
                    }
                    else
                    {
                        length = val[1].second + 1 - val[1].first + 1;
                    }
                    answer = length;
                    cout << "found a subarray of length " << answer << endl;
                }
                count_temp = count_temp/2;
                if(answer > count_temp)
                {
                    cout << " replaced" << endl;
                    count_temp = answer;
                }
            }
            cout << "Found subarray of length " << count_temp << " " << "no of array " << acount <<  " key is " << key << endl;
            max_count = max(max_count, count_temp);
        }
    }
    cout << max_count << endl;
    return 0;
}