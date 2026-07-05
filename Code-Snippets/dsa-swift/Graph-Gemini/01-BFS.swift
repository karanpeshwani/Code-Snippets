import Foundation
import Collections // Apple's Swift Collections for Deque

/*
 BFS (Breadth-First Search)

 Intuition:
 BFS explores a graph level by level, moving uniformly outward from the starting node.
 It visits all direct neighbors of a node before moving on to the neighbors' neighbors.
 We use a Queue data structure to keep track of nodes to visit next (FIFO - First In First Out).

 Usecases & Usage Patterns:
 - Finding the shortest path in an unweighted graph (or grid).
 - Level order traversal of trees or graphs.
 - Finding all connected components in an undirected graph.
 - Social network connections (e.g., finding friends within 1st degree, 2nd degree, etc.).
 - Pattern: Often uses a `visited` array/set to avoid processing a node multiple times (which prevents infinite loops in graphs with cycles).

 Time Complexity: O(V + E)
 - V is the number of vertices, E is the number of edges.
 - We visit each vertex once, which takes O(V) time.
 - For each vertex, we iterate through all its outgoing edges once, taking O(E) time across all vertices.
 
 Space Complexity: O(V)
 - The `visited` array takes O(V) space.
 - The `queue` can hold at most O(V) vertices in the worst case (e.g., a star graph where one central node connects to all others).
*/

func bfsTraversal(V: Int, adj: [[Int]], start: Int) -> [Int] {
    var visited = Array(repeating: false, count: V)
    var result: [Int] = []
    
    // Using Deque from swift-collections for O(1) push and popFirst
    var queue: Deque<Int> = []
    
    // Start with the initial node
    queue.append(start)
    visited[start] = true
    
    while !queue.isEmpty {
        let node = queue.removeFirst()
        result.append(node)
        
        // Traverse all adjacent nodes
        for neighbor in adj[node] {
            if !visited[neighbor] {
                visited[neighbor] = true
                queue.append(neighbor)
            }
        }
    }
    
    return result
}
