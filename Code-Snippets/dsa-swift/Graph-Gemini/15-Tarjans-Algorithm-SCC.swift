import Foundation

/*
 Tarjan's Algorithm for Strongly Connected Components (SCC)

 Intuition:
 Tarjan's algorithm finds SCCs in a directed graph using a single DFS pass (unlike Kosaraju's which needs 2 passes).
 It uses a stack to keep track of the current path and maintains two values for each node:
 1. `discoveryTime`: The time the node was first visited.
 2. `lowestTime`: The lowest discovery time reachable from this node (including back-edges to nodes currently in the recursion stack).
 
 A node is the "head" or "root" of an SCC if, after exploring all its neighbors, its `lowestTime` equals its `discoveryTime`.
 When this happens, all nodes popped from the stack up to this node belong to the same SCC.

 Usecases & Usage Patterns:
 - Better constant factors than Kosaraju's since it's a single pass.
 - Dependency resolution and circular reference detection.

 Time Complexity: O(V + E)
 - Single DFS traversal. We process each vertex and each edge exactly once.

 Space Complexity: O(V)
 - O(V) for arrays `discoveryTime`, `lowestTime`, `inStack`, and the Stack itself.
 - O(V) for the recursive call stack.
*/

func tarjansSCC(V: Int, adj: [[Int]]) -> [[Int]] {
    var discoveryTime = Array(repeating: -1, count: V)
    var lowestTime = Array(repeating: -1, count: V)
    var inStack = Array(repeating: false, count: V)
    var stack: [Int] = []
    
    var time = 0
    var sccs: [[Int]] = []
    
    func dfs(u: Int) {
        time += 1
        discoveryTime[u] = time
        lowestTime[u] = time
        stack.append(u)
        inStack[u] = true
        
        for v in adj[u] {
            if discoveryTime[v] == -1 {
                // Not visited yet, go deeper
                dfs(u: v)
                lowestTime[u] = min(lowestTime[u], lowestTime[v])
            } else if inStack[v] {
                // Visited and in stack -> Back-edge found
                lowestTime[u] = min(lowestTime[u], discoveryTime[v])
            }
        }
        
        // If u is the root of an SCC
        if lowestTime[u] == discoveryTime[u] {
            var currentSCC: [Int] = []
            while true {
                let node = stack.removeLast()
                inStack[node] = false
                currentSCC.append(node)
                if node == u { break }
            }
            sccs.append(currentSCC)
        }
    }
    
    for i in 0..<V {
        if discoveryTime[i] == -1 {
            dfs(u: i)
        }
    }
    
    return sccs
}
