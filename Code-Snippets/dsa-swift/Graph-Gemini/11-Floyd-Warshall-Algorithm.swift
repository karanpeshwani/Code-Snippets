//Again
import Foundation

/*
 Floyd-Warshall Algorithm (Multi-Source Shortest Path)

 Intuition:
 Unlike Dijkstra and Bellman-Ford which find the shortest path from a *single* source, 
 Floyd-Warshall finds the shortest paths between *ALL* pairs of vertices.
 It uses Dynamic Programming. The idea is to incrementally allow vertices to act as an intermediate point.
 For every pair (i, j), we check if going through a vertex `k` (i.e., i -> k -> j) is shorter than the direct path i -> j.
 We do this for all possible intermediate nodes `k` from 0 to V-1.

 Usecases & Usage Patterns:
 - All-pairs shortest path queries.
 - Finding the transitive closure of a directed graph.
 - Also capable of detecting negative weight cycles (if matrix[i][i] becomes negative).

 Time Complexity: O(V^3)
 - We use three nested loops, each iterating V times (k, i, j).
 
 Space Complexity: O(V^2)
 - We need a 2D matrix (Adjacency Matrix) of size V x V to store the shortest distances between every pair of vertices.
*/

func floydWarshall(V: Int, matrix: inout [[Int]]) {
    // matrix[i][j] represents the weight of edge from i to j
    // Initialize non-existing edges with a large value, e.g., Int.max / 2 to avoid overflow on addition
    
    // Using k as the intermediate node
    for k in 0..<V {
        for i in 0..<V {
            for j in 0..<V {
                if matrix[i][k] != Int.max / 2 && matrix[k][j] != Int.max / 2 {
                    matrix[i][j] = min(matrix[i][j], matrix[i][k] + matrix[k][j])
                }
            }
        }
    }
    
    // Negative cycle detection
    for i in 0..<V {
        if matrix[i][i] < 0 {
            print("Negative weight cycle detected!")
        }
    }
}
