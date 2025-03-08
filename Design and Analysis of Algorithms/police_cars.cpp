// C++ program for finding minimum cut using Ford-Fulkerson
#include <iostream>
#include <limits.h>
#include <string.h>
#include <queue>
using namespace std;

// Number of vertices in given graph

#define V 10000000

long long int answer = 0;
int n, m, a, b;

/* Returns true if there is a path from source 's' to sink 't' in
residual graph. Also fills parent[] to store the path */
int bfs(int rGraph[V][V], int s, int t, int parent[])
{
	// Create a visited array and mark all vertices as not visited
	bool visited[n];
	memset(visited, 0, sizeof(visited));

	// Create a queue, enqueue source vertex and mark source vertex
	// as visited
	queue <int> q;
	q.push(s);
	visited[s] = true;
	parent[s] = -1;

	// Standard BFS Loop
	while (!q.empty())
	{
		int u = q.front();
		q.pop();

		for (int v=0; v<n; v++)
		{
			if (visited[v]==false && rGraph[u][v] > 0)
			{
				q.push(v);
				parent[v] = u;
				visited[v] = true;
			}
		}
	}

	// If we reached sink in BFS starting from source, then return
	// true, else false
	return (visited[t] == true);
}

// A DFS based function to find all reachable vertices from s. The function
// marks visited[i] as true if i is reachable from s. The initial values in
// visited[] must be false. We can also use BFS to find reachable vertices
void dfs(int rGraph[V][V], int s, bool visited[])
{
	visited[s] = true;
	for (int i = 0; i < n; i++)
    {
        if (rGraph[s][i] && !visited[i])
        {
            dfs(rGraph, i, visited);
        }
    }
}

// Prints the minimum s-t cut
void minCut(int **graph, int s, int t)
{
	int u, v;

	// Create a residual graph and fill the residual graph with
	// given capacities in the original graph as residual capacities
	// in residual graph
	int rGraph[n][n]; // rGraph[i][j] indicates residual capacity of edge i-j
	for (u = 0; u < n; u++)
    {
        for (v = 0; v < n; v++)
        {
            rGraph[u][v] = graph[u][v];
        }
    }

	int parent[n]; // This array is filled by BFS and to store path

	// Augment the flow while there is a path from source to sink
	// while (bfs(rGraph, s, t, parent))
	// {
	// 	// Find minimum residual capacity of the edges along the
	// 	// path filled by BFS. Or we can say find the maximum flow
	// 	// through the path found.
	// 	int path_flow = INT_MAX;
	// 	for (v=t; v!=s; v=parent[v])
	// 	{
	// 		u = parent[v];
	// 		path_flow = min(path_flow, rGraph[u][v]);
	// 	}

	// 	// update residual capacities of the edges and reverse edges
	// 	// along the path
	// 	for (v=t; v != s; v=parent[v])
	// 	{
	// 		u = parent[v];
	// 		rGraph[u][v] -= path_flow;
	// 		rGraph[v][u] += path_flow;
	// 	}
	// }

	// Flow is maximum now, find vertices reachable from s
	bool visited[n];
	memset(visited, false, sizeof(visited));
	// dfs(rGraph, s, visited);

	// Print all edges that are from a reachable vertex to
	// non-reachable vertex in the original graph
	for(int i = 0; i < n; i++)
    {
        for(int j = 0; j < n; j++)
        {
            if(visited[i] && !visited[j] && graph[i][j])
            {
                // cout << i << " - " << j << endl;
                answer = answer + graph[i][j];
            }
        }
    }
	return;
}

// Driver program to test above functions
int main()
{
    scanf("%d %d %d %d", &n, &m, &a, &b);
	// Let us create a graph shown in the above example
    int **graph;
    for(int i=0; i<m; i++)
    {
        int l, r, c;
        scanf("%d %d %d", &l, &r, &c);
        graph[l-1][r-1] = c;
        graph[r-1][l-1] = c;
    }

	minCut(graph, a-1, b-1);

	return 0;
}