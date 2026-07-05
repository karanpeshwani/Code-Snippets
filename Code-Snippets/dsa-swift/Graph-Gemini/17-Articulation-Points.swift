import Foundation

/*
 Articulation Point / Vertex (Tarjan's Approach)

 Intuition:
 An Articulation Point (or cut-vertex) is a vertex in an undirected graph whose removal increases the number of disconnected components.
 We use DFS with `discoveryTime` and `lowestTime` arrays.
 A node `u` is an articulation point if:
 1. It is the root of the DFS tree and has AT LEAST 2 independent children.
 2. It is NOT the root, and it has a child `v` such that `lowestTime[v] >= discoveryTime[u]`. 
    This means the child `v` and its descendants have no back-edge to an ancestor of `u`. They are entirely dependent on `u` to connect to the rest of the graph.

 Note: Unlike bridges where the condition is strictly greater (`>`), here it is greater than OR equal (`>=`).

 Usecases & Usage Patterns:
 - Identifying single points of failure in servers or routers.
 - Finding critical routers in a topology.

 Time Complexity: O(V + E)
 - Single DFS traversal.

 Space Complexity: O(V)
 - O(V) for the arrays and recursion stack.
*/

func findArticulationPoints(V: Int, adj: [[Int]]) -> [Int] {
    var discoveryTime = Array(repeating: -1, count: V)
    var lowestTime = Array(repeating: -1, count: V)
    var isArticulationPoint = Array(repeating: false, count: V) // Use a boolean array to prevent duplicates
    var time = 0
    
    func dfs(u: Int, parent: Int) {
        time += 1
        discoveryTime[u] = time
        lowestTime[u] = time
        var childrenCount = 0
        
        for v in adj[u] {
            if v == parent { continue }
            
            if discoveryTime[v] == -1 {
                // Unvisited neighbor -> it's a child in the DFS tree
                childrenCount += 1
                dfs(u: v, parent: u)
                
                lowestTime[u] = min(lowestTime[u], lowestTime[v])
                
                // Condition 2: Not root and lowest reachable time of child >= discovery time of current
                if parent != -1 && lowestTime[v] >= discoveryTime[u] {
                    isArticulationPoint[u] = true
                }
            } else {
                // Back-edge
                lowestTime[u] = min(lowestTime[u], discoveryTime[v])
            }
        }
        
        // Condition 1: Root of DFS with >= 2 independent children
        if parent == -1 && childrenCount > 1 {
            isArticulationPoint[u] = true
        }
    }
    
    for i in 0..<V {
        if discoveryTime[i] == -1 {
            dfs(u: i, parent: -1)
        }
    }
    
    // Extract actual vertices that are articulation points
    var result: [Int] = []
    for i in 0..<V {
        if isArticulationPoint[i] {
            result.append(i)
        }
    }
    return result
}
