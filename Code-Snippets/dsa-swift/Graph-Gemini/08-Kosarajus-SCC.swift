//Again
import Foundation

/*
 Kosaraju's Algorithm for Strongly Connected Components (SCC)

 Intuition:
 A Strongly Connected Component in a directed graph is a sub-graph where every node can reach every other node.
 Kosaraju's algorithm finds all SCCs in a directed graph using 2 passes of DFS.
 
 Steps:
 1. Sort all nodes based on their finishing times. (DFS 1)
    - We do a DFS and put a node in a stack ONLY after exploring all its descendants. 
    - This gives us nodes in order of their topological dependencies.
 2. Reverse the graph.
    - Since SCCs form cycles, reversing the edges won't change the nodes that make up an SCC.
    - It ensures that traversing an SCC doesn't "leak" into another SCC because the reverse graph blocks paths from later SCCs back to earlier ones.
 3. Do DFS on the reversed graph in the order of nodes in the stack. (DFS 2)
    - Pop nodes from the stack, and if unvisited, perform DFS on the reversed graph. Each successful DFS call marks one SCC.

 Usecases & Usage Patterns:
 - Understanding structure of complex networks (e.g., the web, communication networks).
 - Identifying tightly coupled clusters.
 - 2-SAT problems (boolean satisfiability).

 Time Complexity: O(V + E)
 - DFS 1 takes O(V + E).
 - Reversing the graph takes O(V + E).
 - DFS 2 takes O(V + E).
 - Total: O(V + E).

 Space Complexity: O(V + E)
 - O(V + E) to store the reversed graph.
 - O(V) for the Stack.
 - O(V) for the `visited` array and recursive Call Stack.
*/

func kosarajuSCC(V: Int, adj: [[Int]]) -> [[Int]] {
    var visited = Array(repeating: false, count: V)
    var stack: [Int] = []
    
    // 1. Sort nodes by finishing time
    func dfs1(node: Int) {
        visited[node] = true
        for neighbor in adj[node] {
            if !visited[neighbor] {
                dfs1(node: neighbor)
            }
        }
        stack.append(node)
    }
    
    for i in 0..<V {
        if !visited[i] {
            dfs1(node: i)
        }
    }
    
    // 2. Reverse the graph
    var reversedAdj = Array(repeating: [Int](), count: V)
    for u in 0..<V {
        for v in adj[u] {
            reversedAdj[v].append(u)
        }
    }
    
    // 3. Perform DFS based on finishing time (stack order)
    visited = Array(repeating: false, count: V) // Reset visited
    var sccs: [[Int]] = []
    var currentSCC: [Int] = []
    
    func dfs2(node: Int) {
        visited[node] = true
        currentSCC.append(node)
        for neighbor in reversedAdj[node] {
            if !visited[neighbor] {
                dfs2(node: neighbor)
            }
        }
    }
    
    // Traverse based on stack (popping from the top)
    while !stack.isEmpty {
        let node = stack.removeLast()
        if !visited[node] {
            currentSCC = []
            dfs2(node: node)
            sccs.append(currentSCC)
        }
    }
    
    return sccs
}
