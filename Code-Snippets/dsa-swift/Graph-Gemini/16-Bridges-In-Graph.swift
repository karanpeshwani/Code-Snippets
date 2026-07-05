import Foundation

/*
 Bridges in Graph (Tarjan's Approach)

 Intuition:
 A bridge (or cut-edge) is an edge in a graph whose removal increases the number of disconnected components.
 We can find all bridges using DFS, similar to Tarjan's SCC logic.
 We maintain `discoveryTime` and `lowestTime` for each node.
 When exploring an edge u - v:
 If `lowestTime[v] > discoveryTime[u]`, it means the ONLY way to reach node `v` (and its descendants) 
 from the rest of the graph is through the edge `u - v`. There are no back-edges providing an alternative route.
 Therefore, `u - v` is a bridge.

 Usecases & Usage Patterns:
 - Identifying single points of failure in networks (e.g., a critical road connecting two cities).
 - Analyzing network vulnerabilities.

 Time Complexity: O(V + E)
 - We do a single DFS pass, touching every vertex and edge once.

 Space Complexity: O(V)
 - O(V) for the `discoveryTime` and `lowestTime` arrays.
 - O(V) for the recursive call stack.
*/

func findBridges(V: Int, adj: [[Int]]) -> [[Int]] {
    var discoveryTime = Array(repeating: -1, count: V)
    var lowestTime = Array(repeating: -1, count: V)
    var bridges: [[Int]] = []
    var time = 0
    
    func dfs(u: Int, parent: Int) {
        time += 1
        discoveryTime[u] = time
        lowestTime[u] = time
        
        for v in adj[u] {
            if v == parent { continue } // Ignore the edge we just came from
            
            if discoveryTime[v] == -1 {
                // Not visited yet
                dfs(u: v, parent: u)
                
                // Update lowest time based on the child's lowest time
                lowestTime[u] = min(lowestTime[u], lowestTime[v])
                
                // Check bridge condition
                if lowestTime[v] > discoveryTime[u] {
                    bridges.append([u, v])
                }
            } else {
                // Back-edge found, update lowest reachable time
                lowestTime[u] = min(lowestTime[u], discoveryTime[v])
            }
        }
    }
    
    // Handle disconnected components
    for i in 0..<V {
        if discoveryTime[i] == -1 {
            dfs(u: i, parent: -1)
        }
    }
    
    return bridges
}
