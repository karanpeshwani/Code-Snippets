import Foundation
import Collections

/*
 Bipartite Graph

 Intuition:
 A graph is Bipartite if its nodes can be colored using exactly 2 colors such that no two adjacent nodes have the same color.
 We can try coloring the graph level-by-level (BFS) or depth-wise (DFS).
 If we ever find an adjacent node that is already visited AND has the same color as the current node, the graph is NOT bipartite.
 Any graph with an odd-length cycle cannot be bipartite. Trees and even-length cycle graphs are bipartite.

 Usecases & Usage Patterns:
 - Dividing sets into two independent groups (e.g., pairing problems, matching algorithms).
 - Coloring problems where conflicts must be avoided.
 - Job assignments (e.g., Workers and Tasks).

 Time Complexity: O(V + E)
 - We visit every node and check every edge once.

 Space Complexity: O(V)
 - O(V) for the `color` array.
 - O(V) for the Queue (BFS) or Call Stack (DFS).
*/

// MARK: - Using BFS
func isBipartiteBFS(V: Int, adj: [[Int]]) -> Bool {
    // color array: -1 means uncolored, 0 and 1 are the two colors
    var colors = Array(repeating: -1, count: V)
    
    func bfs(start: Int) -> Bool {
        var queue: Deque<Int> = []
        queue.append(start)
        colors[start] = 0 // start with color 0
        
        while !queue.isEmpty {
            let node = queue.removeFirst()
            
            for neighbor in adj[node] {
                if colors[neighbor] == -1 {
                    // Color with opposite color
                    colors[neighbor] = 1 - colors[node]
                    queue.append(neighbor)
                } else if colors[neighbor] == colors[node] {
                    // Adjacent node has the same color -> Not Bipartite
                    return false
                }
            }
        }
        return true
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if colors[i] == -1 {
            if !bfs(start: i) { return false }
        }
    }
    
    return true
}

// MARK: - Using DFS
func isBipartiteDFS(V: Int, adj: [[Int]]) -> Bool {
    var colors = Array(repeating: -1, count: V)
    
    func dfs(node: Int, color: Int) -> Bool {
        colors[node] = color
        
        for neighbor in adj[node] {
            if colors[neighbor] == -1 {
                if !dfs(node: neighbor, color: 1 - color) {
                    return false
                }
            } else if colors[neighbor] == color {
                // Adjacent node has the same color
                return false
            }
        }
        return true
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if colors[i] == -1 {
            if !dfs(node: i, color: 0) {
                return false
            }
        }
    }
    
    return true
}
