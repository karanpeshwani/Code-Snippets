import Foundation
import Collections

/*
 Detect A Cycle in Directed Graph

 Intuition:
 - **DFS**: In a directed graph, finding a `visited` node doesn't always mean there's a cycle (it could just be a cross edge).
   A cycle only exists if we visit a node that is currently in our active "recursion stack" (i.e., we are still exploring its descendants).
   We use `visited` to track all processed nodes, and `pathVisited` (or recursion stack array) to track nodes in the current path.
 - **BFS (Toposort/Kahn's Algo)**: Topological sort is only possible for Directed Acyclic Graphs (DAGs).
   If we attempt Kahn's algorithm and the number of nodes processed is less than V, it means some nodes had dependencies (in-degrees) that never reached 0, implying a cycle.

 Usecases & Usage Patterns:
 - Deadlock detection in OS (Resource Allocation Graph).
 - Circular dependency detection in build systems (e.g., resolving package dependencies).

 Time Complexity: O(V + E)
 - DFS and BFS both process each vertex and each directed edge at most once.

 Space Complexity: O(V)
 - DFS: O(V) for `visited`, O(V) for `pathVisited`, and O(V) for call stack.
 - BFS: O(V) for `inDegree` array and O(V) for Queue.
*/

// MARK: - Using DFS
func hasCycleDirectedDFS(V: Int, adj: [[Int]]) -> Bool {
    var visited = Array(repeating: false, count: V)
    var pathVisited = Array(repeating: false, count: V)
    
    func dfs(node: Int) -> Bool {
        visited[node] = true
        pathVisited[node] = true // Mark node in current path
        
        for neighbor in adj[node] {
            if !visited[neighbor] {
                if dfs(node: neighbor) { return true }
            } else if pathVisited[neighbor] {
                // If it's already visited AND in the current recursion path -> Cycle!
                return true
            }
        }
        
        // Backtrack: remove from current path when exploring descendants is done
        pathVisited[node] = false
        return false
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if !visited[i] {
            if dfs(node: i) {
                return true
            }
        }
    }
    
    return false
}

// MARK: - Using BFS (Topological Sort / Kahn's Algo)
func hasCycleDirectedBFS(V: Int, adj: [[Int]]) -> Bool {
    var inDegree = Array(repeating: 0, count: V)
    
    // Calculate in-degrees
    for i in 0..<V {
        for neighbor in adj[i] {
            inDegree[neighbor] += 1
        }
    }
    
    var queue: Deque<Int> = []
    
    // Add nodes with 0 in-degree (no dependencies)
    for i in 0..<V {
        if inDegree[i] == 0 {
            queue.append(i)
        }
    }
    
    var processedCount = 0
    
    while !queue.isEmpty {
        let node = queue.removeFirst()
        processedCount += 1
        
        for neighbor in adj[node] {
            inDegree[neighbor] -= 1
            if inDegree[neighbor] == 0 {
                queue.append(neighbor)
            }
        }
    }
    
    // If we couldn't process all nodes, there must be a cycle
    return processedCount != V
}
