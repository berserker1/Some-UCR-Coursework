#include<iostream>
#include<vector>
#include<tuple>
#include<queue>
#include<map>

using namespace std;

typedef tuple<long long int, long long int, long long int, long long int, long long int, long long int> sofa;
typedef tuple<long long int> classroom;
typedef std::map<int, int, std::greater<int> > MyMap;


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
    MyMap rooms;
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
        cout << "Current element ";
        printsofa(t[i]);
        if(rooms.size() == 0)
        {
            cout << "adding in map because is empty " << endl;
            countk++;
            rooms[get<2>(t[i])] = -1;
        }
        else
        {
            cout << "Finding just less than " << get<0>(t[i]) << endl;
            MyMap::iterator it = rooms.upper_bound(get<0>(t[i]));
            cout << "Found this value " << it->second << endl;
            if(it->second == 0)
            {
                if(countk >= k)
                {
                    cout << "Ignoring";
                    printsofa(t[i]);
                    removek++;
                }
                else
                {
                    cout << "added new key " << endl;
                    rooms[get<2>(t[i])] = -1;
                    countk++;
                }
            }
            else
            {
                cout << "replace with new key" << endl;
                auto node = rooms.extract(it->first);
                node.key() = get<2>(t[i]);
                rooms.insert(std::move(node));
            }
        }
    }
    cout << removek << endl;
    return 0;
}