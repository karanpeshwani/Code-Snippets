import Foundation
import Collections

/*
 Detect A Cycle in Undirected Graph
 
 Intuition:
 In an undirected graph, an edge goes both ways (A-B means B-A). When exploring neighbors, 
 you will naturally see the node you just came from. 
 A cycle exists if you encounter a `visited` node that is NOT the `parent` (the node that led you here).
 If it's visited and not the parent, it means there's another path to this node, forming a loop.

 Usecases & Usage Patterns:
 - Validating if a given graph is a valid Tree (a tree is a connected graph with no cycles).
 - Network topology analysis (identifying redundant pathways).

 Time Complexity: O(V + E)
 - We traverse all vertices and edges at most once (BFS or DFS).
 
 Space Complexity: O(V)
 - O(V) for `visited` array.
 - O(V) for Queue (in BFS) or Call Stack (in DFS).
*/

// MARK: - Using BFS
func hasCycleUndirectedBFS(V: Int, adj: [[Int]]) -> Bool {
    var visited = Array(repeating: false, count: V)
    
    func bfs(start: Int) -> Bool {
        // Queue stores a tuple of (currentNode, parentNode)
        var queue: Deque<(node: Int, parent: Int)> = []
        queue.append((start, -1))
        visited[start] = true
        
        while !queue.isEmpty {
            let (node, parent) = queue.removeFirst()
            
            for neighbor in adj[node] {
                if !visited[neighbor] {
                    visited[neighbor] = true
                    queue.append((neighbor, node))
                } else if neighbor != parent {
                    // Visited and not the parent -> cycle detected!
                    return true
                }
            }
        }
        return false
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if !visited[i] {
            if bfs(start: i) {
                return true
            }
        }
    }
    
    return false
}

// MARK: - Using DFS
func hasCycleUndirectedDFS(V: Int, adj: [[Int]]) -> Bool {
    var visited = Array(repeating: false, count: V)
    
    func dfs(node: Int, parent: Int) -> Bool {
        visited[node] = true
        
        for neighbor in adj[node] {
            if !visited[neighbor] {
                if dfs(node: neighbor, parent: node) {
                    return true
                }
            } else if neighbor != parent {
                // Visited and not the parent -> cycle detected!
                return true
            }
        }
        
        return false
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if !visited[i] {
            if dfs(node: i, parent: -1) {
                return true
            }
        }
    }
    
    return false
}
