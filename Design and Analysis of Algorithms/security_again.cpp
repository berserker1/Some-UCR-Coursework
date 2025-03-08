#include<iostream>
#include<vector>
#include<tuple>
#include<queue>
 
using namespace std;
 
typedef tuple<long long int, long long int, long long int, long long int, long long int, long long int> sofa;
typedef tuple<long long int> classroom;
 
 
int countk=0;
int removek=0;
int printsofa(sofa elem)
{
    cout << "Element is " << get<0>(elem) << " " << get<2>(elem) << endl;
    return 0;
}
 
int printclass(classroom elem)
{
    cout << "Element is " << get<0>(elem) << endl;
    return 0;
}
 
int compare(sofa lhs, sofa rhs)
{
    if(get<2>(lhs) < get<2>(rhs))
    {
        return 1;
    }
    else if(get<2>(lhs) == get<2>(rhs))
    {
        return (get<4>(lhs) < get<4>(rhs));
    }
    else
    {
        return 0;
    }
}
int compatible(sofa elem, classroom b)
{
    // classroom a = make_tuple(get<0>(elem));
    if(get<0>(elem) > get<0>(b))
    {
        // cout << "compatible" << endl;
        // printclass(a);
        // printclass(b);
        return 1;
    }
    else
    {
        // cout << "not compatible" << endl;
        // printclass(a);
        // printclass(b);
        return 0;
    }
}
int main()
{
    long long int l, n, k;
    scanf("%lld %lld %lld", &l, &n, &k);
    long long int obstacles = 0;
    // for(long long int i=0; i<n; i++)
    // {
    //     a[i] = 0;
    // }
    // priority_queue <sofa, vector<sofa>, decltype(cmp) > pqueue;
    auto cmp = [](const classroom lhs, const classroom rhs)
    {
        if(get<0>(lhs) < get<0>(rhs))
        {
            return 0;
        }
        else
        {
            return 1;
        }
    };
    priority_queue <classroom, vector<classroom>, decltype(cmp)> pqueue;
    vector<sofa> t;
    for(long long int i=0; i<n; i++)
    {
        long long int a, b, c, d, obstructions;
        scanf("%lld %lld %lld %lld", &a, &b, &c, &d);
        obstructions = c - a + 1;
        sofa one = make_tuple(a, b, c, d, obstructions, 0);
        // pqueue.push(one);
        t.push_back(one);
    }
    sort(t.begin(), t.end(), compare);
    // cout << "after sorting" << endl;
    // for(long long int i=0; i<t.size(); i++)
    // {
    //     printsofa(t[i]);
    // }
    if(k == 0)
    {
        cout << n << endl;
        return 0;
    }
    for(long long int i=0; i<t.size(); i++)
    {
        // cout << "Current element ";
        // printsofa(t[i]);
        if(pqueue.size() == 0)
        {
            pqueue.push(make_tuple(get<2>(t[i])));
            // cout << "adding because queue is empty " << endl;
            countk++;
        }
        else
        {
            // cout << "Current top ";
            // printclass(pqueue.top());
            classroom lowest = pqueue.top();
            if(!compatible(t[i], lowest))
            {
                if(countk >= k)
                {
                    // cout << " Ignoring ";
                    // printsofa(t[i]);
                    removek++;
                }
                else
                {
                    classroom new_one = make_tuple(get<2>(t[i]));
                    pqueue.push(new_one);
                    countk++;
                }
            }
            else
            {
                // cout << "Removing ";
                // printclass(pqueue.top());
                pqueue.pop();
                classroom new_one = make_tuple(get<2>(t[i]));
                pqueue.push(new_one);
            }
        }
    }
    cout << removek << endl;
    return 0;
}