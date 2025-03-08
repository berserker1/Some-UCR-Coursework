#include<iostream>
#include<vector>
#include<queue>

using namespace std;

typedef pair<long long int, int> pi;
int main()
{
    long long int M;
    vector <pi> price;
    long long int a[9];
    for(int i=0; i<10; i++)
    {
        a[i] = 0;
    }
    priority_queue <pi, vector<pi>, greater<pi> > qu;
    // priority_queue <pi> qu_max;
    scanf("%lld", &M);
    cout << "Done M" << endl;
    for(int i=0; i<9; i++)
    {
        int a;
        scanf("%d", &a);
        qu.push(make_pair(a, i+1));
        price.push_back(make_pair(i+1, a));
    }
    // sort(price.begin(), price.end());
    cout << "Price after sorting" << endl;
    for(int k=0; k<price.size(); k++)
    {
        cout << price[k].first << " " << price[k].second << endl;
    }
    long long int total_length = M/qu.top().first;
    long long int array[total_length];
    long long int actual_array[total_length];
    long long int j;
    long long int total_cost = total_length * qu.top().first;
    pi min_p = qu.top();
    cout << "Minimum " << min_p.first << " " << min_p.second << endl;
    for(j=0; j<total_length; j++)
    {
        array[j] = qu.top().first;
        actual_array[j] = qu.top().second;
    }
    for(j=0; j<total_length; j++)
    {
        long long int new_cost = total_cost - array[j];
        long long int M_r = M - new_cost;
        cout << "New cost " << new_cost << " " << "M_r " << M_r << endl;
        int k;
        for(k=price.size() - 1; k>=0; k--)
        {
            pi current = price[k];
            cout << "Current " << current.first << " " << current.second << endl;
            if(current == min_p)
            {
                break;
            }
            if((M_r / current.second) > 0)
            {
                array[j] = current.second;
                total_cost = new_cost + current.second;
                actual_array[j] = current.first;
                cout << "Applied " << current.second << " total cost " << total_cost << " applied at " << j << " " << "value " << current.first << endl;
                break;
            }
        }
    }
    string output="";
    for(j=0; j<total_length; j++)
    {
        output.append(to_string(actual_array[j]));
    }
    cout << "Output" << endl;
    cout << output << endl;
    return 0;
}