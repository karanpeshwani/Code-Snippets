// 1192. Critical Connections in a Network
// https://leetcode.com/problems/critical-connections-in-a-network/

/*
 Time Complexity: O(V + E), where V is the number of servers (n) and E is the number of connections. We build the adjacency list in O(E) time and perform a single Depth First Search (DFS) which visits each vertex and edge once in O(V + E) time.
 Space Complexity: O(V + E) to store the graph as an adjacency list. The `disc` and `low` arrays each take O(V) space, and the recursion call stack can go up to O(V) deep in the worst case (e.g., a linear graph).
*/

class Solution {
    func criticalConnections(_ n: Int, _ connections: [[Int]]) -> [[Int]] {
        // Build the graph using an adjacency list
        var graph = [[Int]](repeating: [], count: n)
        for connection in connections {
            let u = connection[0]
            let v = connection[1]
            graph[u].append(v)
            graph[v].append(u)
        }
        
        var disc = [Int](repeating: -1, count: n) // Discovery time of each node
        var low = [Int](repeating: -1, count: n)  // Lowest discovery time reachable from each node
        var time = 0
        var criticalEdges = [[Int]]()
        
        // Tarjan's Bridge-Finding Algorithm
        func dfs(_ curr: Int, _ parent: Int) {
            disc[curr] = time
            low[curr] = time
            time += 1
            
            for neighbor in graph[curr] {
                // Ignore the edge back to the parent to prevent false back-edges
                if neighbor == parent { continue }
                
                if disc[neighbor] == -1 {
                    // Node is not visited yet
                    dfs(neighbor, curr)
                    
                    // Update the lowest reachable time of current node based on the child's lowest time
                    low[curr] = min(low[curr], low[neighbor])
                    
                    // If the lowest vertex reachable from the subtree under neighbor is
                    // strictly greater than the discovery time of curr, then curr-neighbor is a bridge.
                    if low[neighbor] > disc[curr] {
                        criticalEdges.append([curr, neighbor])
                    }
                } else {
                    // Node is already visited, this is a back edge.
                    // We update low[curr] with the discovery time of the neighbor.
                    low[curr] = min(low[curr], disc[neighbor])
                }
            }
        }
        
        // Start DFS from node 0 (assuming a fully connected network as per problem description)
        dfs(0, -1)
        
        return criticalEdges
    }
}
