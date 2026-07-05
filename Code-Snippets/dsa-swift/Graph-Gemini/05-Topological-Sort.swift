import Foundation
import Collections

/*
 Topological Sort

 Intuition:
 Topological sorting provides a linear ordering of vertices such that for every directed edge U -> V, 
 vertex U comes before V in the ordering. It is ONLY possible in Directed Acyclic Graphs (DAGs).
 - **Kahn's Algo (BFS)**: Uses the concept of In-Degree (number of incoming edges). Nodes with 0 in-degree have no prerequisites, 
   so they go first. As we process them, we remove their outgoing edges (decrementing neighbors' in-degrees) and add new 0 in-degree nodes.
 - **DFS + Stack**: We explore as deep as possible. A node has finished exploring all its descendants when we reach the end of its DFS call. 
   At this point, we push it to a Stack. Since we push nodes when they have no unvisited dependencies left, 
   reversing the stack (or popping from it) gives the topological order.

 Usecases & Usage Patterns:
 - Task scheduling with prerequisites (e.g., course schedule, build systems).
 - Data serialization dependencies.
 - Finding shortest/longest paths in a DAG.

 Time Complexity: O(V + E)
 - Both BFS and DFS examine every node and edge once.

 Space Complexity: O(V)
 - BFS: O(V) for `inDegree` array, Queue, and Result array.
 - DFS: O(V) for `visited`, Call Stack, and Result Stack.
*/

// MARK: - Using Queue + BFS (Kahn's Algo)
func topologicalSortBFS(V: Int, adj: [[Int]]) -> [Int] {
    var inDegree = Array(repeating: 0, count: V)
    
    for i in 0..<V {
        for neighbor in adj[i] {
            inDegree[neighbor] += 1
        }
    }
    
    var queue: Deque<Int> = []
    for i in 0..<V {
        if inDegree[i] == 0 {
            queue.append(i)
        }
    }
    
    var topoOrder: [Int] = []
    
    while !queue.isEmpty {
        let node = queue.removeFirst()
        topoOrder.append(node)
        
        for neighbor in adj[node] {
            inDegree[neighbor] -= 1
            if inDegree[neighbor] == 0 {
                queue.append(neighbor)
            }
        }
    }
    
    // Note: If topoOrder.count != V, a cycle exists (not a DAG)
    return topoOrder
}

// MARK: - Using Stack + DFS
func topologicalSortDFS(V: Int, adj: [[Int]]) -> [Int] {
    var visited = Array(repeating: false, count: V)
    var stack: [Int] = []
    
    func dfs(node: Int) {
        visited[node] = true
        
        for neighbor in adj[node] {
            if !visited[neighbor] {
                dfs(node: neighbor)
            }
        }
        
        // Push node to stack only after all its dependencies are resolved
        stack.append(node)
    }
    
    for i in 0..<V {
        if !visited[i] {
            dfs(node: i)
        }
    }
    
    // Stack contains the topological sort in reverse order
    return stack.reversed()
}
