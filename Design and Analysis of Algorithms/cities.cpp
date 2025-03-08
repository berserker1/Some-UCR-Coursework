// C++ program to find all the reachable nodes
// for every node present in arr[0..n-1].
#include <iostream>
#include <vector>
#include <queue>
#include <list>
#include <set>
#include <unordered_map>
#include <list>
#include <stack>
// #include <algorithm>

using namespace std;


vector<bool> used;
vector<int> order, component;

int BFS(int node, vector<vector<int>> edges, bool visited[])
{
    list<int> queue;
    visited[node] = true;
    queue.push_back(node);

    // list<int>::iterator i;
    while(!queue.empty())
    {
        node = queue.front();
        queue.pop_front();
        // cout << "started with node " << node << endl;
        for(int j = 0; j < edges[node].size(); j++)
        {
            int neighbour = edges[node][j];
            if(!visited[neighbour])
            {
                visited[neighbour] = true;
                // cout << "made visisted true and added to the queue " << endl;
                queue.push_back(neighbour);
            }
        }
    }
    return 0;
}
bool check(vector<int> nodes, vector<vector<int>> edges, int total)
{
    int n = total;
    bool visited[n+1];
    // used.assign(n+1, false);
    // int **graph = (int **)malloc((n+1) * sizeof(int *));
    // for(int i=0; i<nodes.size(); i++)
    // {
    //     cout << "node is " << nodes[i] << " nieghbours are " << endl;
    //     for(int j=0; j<edges[nodes[i]].size(); j++)
    //     {
    //         cout << edges[nodes[i]][j] << " ";
    //     }
    //     cout << endl;
    // }
    // for(int i=1; i<=n; i++)
    // {
    //     for(int j=1; j<=n; j++)
    //     {
    //         cout << graph[i][j] << " ";
    //     }
    //     cout << endl;
    // }
    for(int i=0; i<=n; i++)
    {
        visited[i] = false;
    }
    BFS(nodes[0], edges, visited);
    // vector<int> new_nodes;
    // vector<vector<int>> rev_edges(n+1);
    // for(int i=0; i<n; i++)
    // {
    //     new_nodes.push_back(nodes[i]);
    // }
    // for(int k=0; k<n; k++)
    // {
    //     int nt = nodes[k];
    //     // cout << "node is " << nt << " neighbours are " << edges[nt].size() << endl;
    //     for(int j=0; j<edges[nt].size(); j++)
    //     {
    //         rev_edges[edges[nt][j]].push_back(nt);
    //         // cout << edges[nt][j] << " ";
    //     }
    //     // cout << endl;
    // }
    // cout << "done " << endl;
    // BFS(nodes[0], rev_edges, visited2);
    // cout <<"now visited and visited 2 " << endl;
    // for(int i=0; i<=n; i++)
    // {
    //     cout << visited[i] << " " << visited2[i] << endl;
    // }
    int count = 0;
    for(int i=0; i<nodes.size(); i++)
    {
        if(visited[nodes[i]] == true)
        {
            // cout << "this node " << nodes[i] << " is true" << endl;
            count++;
        }
    }
    if(count != nodes.size())
    {
        return false;
    }
    return true;
}
void dfs1(int v, vector<vector<int>> adj)
{
    // cout << "doing dfs 1 of " << v << endl;
    used[v] = true;
    stack<int> st;
    stack<int> st2;
    st.push(v);
    st2.push(v);
    while (!st.empty())
    {
        int u = st.top();
        // cout << "Found connecting node " << u << endl;
        st.pop();
        for(auto l: adj[u])
        {
            if (!used[l])
            {
                used[l] = true;
                st.push(l);
                st2.push(l);
            }
        }
        
        order.push_back(st2.top());
        st2.pop();
    }
    // used[v] = true;
    // for (auto u : adj[v])
    // {
    //     // cout << "Found connecting node " << u << endl;
    //     if (!used[u])
    //     {
    //         dfs1(u, adj);
    //     }
    // }
    // order.push_back(v);
}

void dfs2(int v, vector<vector<int>> adj_rev)
{
    // cout << "doing dfs 2 of " << v << endl;
    used[v] = true;
    stack<int> st;
    st.push(v);
    while (!st.empty())
    {
        int u = st.top();
        // cout << "Found connecting node " << u << endl;
        component.push_back(u);
        st.pop();
        for(auto l: adj_rev[u])
        {
            if (!used[l])
            {
                used[l] = true;
                st.push(l);
            }
        }
    }
}

int main()
{
    int n, m;
    // ... read n ...
    scanf("%d %d", &n, &m);

    // continuing from previous code
    vector<vector<int>> adj(n+1), adj_rev(n+1);
    for (int i=0; i<m; i++)
    {
        int a, b;
        scanf("%d %d", &a, &b);
        // cout << "a is " << a << " b is " << b << endl;
        // ... read next directed edge (a,b) ...
        adj[a].push_back(b);
        adj_rev[b].push_back(a);
    }
    // for(int i=1; i<adj.size(); i++)
    // {
    //     cout << "node is " << i << endl;
    //     for(int j=0; j<adj[i].size(); j++)
    //     {
    //         cout << "neighbour is " << adj[i][j] << endl;
    //     }
    // }
    used.assign(n+1, false);

    for (int i = 1; i <= n; i++)
    {
        if (!used[i])
        {
            dfs1(i, adj);
        }
    }

    used.assign(n+1, false);
    // cout << "order " << endl;
    // for(auto i: order)
    // {
    //     cout << i << " ";
    // }
    // cout << endl;

    reverse(order.begin(), order.end());
    vector<int> roots(n+1, 0);
    vector<int> root_nodes;

    for (auto v : order)
    {
        if (!used[v])
        {
            dfs2(v, adj_rev);
            int root = component.front();
            for (auto u : component)
            {
                roots[u] = root;
            }
            root_nodes.push_back(root);
            component.clear();
        }
    }
    // free(used)
    // cout << "done both dfs root node size " << root_nodes.size() << endl;
    sort(root_nodes.begin(), root_nodes.end());
    // adj_rev.clear();
    // sort(root_nodes_c.begin(), root_nodes_c.end());
    // cout << "roots" << endl;
    // for(int i=1; i<=n; i++)
    // {
    //     cout << roots[i] << endl;
    // }
    // for(int i=0; i<root_nodes.size(); i++)
    // {
    //     cout << root_nodes[i] << " ";
    // }
    // cout << endl;
    // adj.clear();
    adj_rev.clear();
    vector<vector<int>> adj_scc(n+1);
    vector<vector<int>> adj_scc_c(n+1);
    for (int v = 1; v <= n; v++)
    {
        // cout << "now node is " << v << endl;
        for (auto u : adj[v])
        {
            // cout << "adjacent of node " << v << " is " << u << endl;
            int root_v = roots[v];
            int root_u = roots[u];

            // cout << "their parents are " << root_v << " and " << root_u << endl;
            if (root_u != root_v)
            {
                // cout << "adding " << endl;
                adj_scc[root_v].push_back(root_u);
                adj_scc[root_u].push_back(root_v);
                adj_scc_c[root_v].push_back(root_u);
                // adj_scc_c[root_u].push_back(root_v);
            }
        }
    }

    // for(int i=0; i<root_nodes.size(); i++)
    // {
    //     cout << root_nodes[i] << " ";
    // }
    // cout << "here" << endl;
    // for(int i=0; i<root_nodes.size(); i++)
    // {
    //     cout << "node is " << root_nodes[i] << " nieghbours are " << endl;
    //     for(int j=0; j<adj_scc_c[root_nodes[i]].size(); j++)
    //     {
    //         cout << adj_scc_c[root_nodes[i]][j] << " ";
    //     }
    //     cout << endl;
    // }
    if (!check(root_nodes, adj_scc, n))
    {
        // cout << "it does not have anyone " << endl;
        cout << 0 << endl;
        return 0;
    }
    // cout << "done checking" << endl;
    vector<int> answer;
    for(int i=0; i<root_nodes.size(); i++)
    {
        if(adj_scc_c[root_nodes[i]].size() == 0)
        {
            for(int j=1; j<=n; j++)
            {
                if(roots[j] == root_nodes[i])
                {
                    answer.push_back(j);
                }
            }
            break;
        }
    }
    sort(answer.begin(), answer.end());
    printf("%zu\n", answer.size());
    for(int i=0; i<answer.size()-1; i++)
    {
        printf("%d ", answer[i]);
    }
    printf("%d\n", answer[answer.size()-1]);
    return 0;
}