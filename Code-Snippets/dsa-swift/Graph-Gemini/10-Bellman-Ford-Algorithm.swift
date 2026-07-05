import Foundation

/*
 Bellman-Ford Algorithm (Single Source Shortest Path - SSSP)

 Intuition:
 While Dijkstra works great, it fails if the graph has negative weight edges (it might get stuck in an infinite loop or give wrong results).
 Bellman-Ford can handle negative weights. The core idea is "relaxation".
 If a graph has V vertices, the longest possible shortest path without a cycle is V-1 edges long.
 Bellman-Ford simply relaxes ALL edges exactly (V-1) times. By the (V-1)th iteration, all shortest paths are guaranteed to be found.
 If we relax all edges one more time (the V-th time) and a distance still decreases, it means the graph contains a Negative Weight Cycle.

 Usecases & Usage Patterns:
 - Financial markets (Arbitrage detection using negative weight cycles).
 - Routing protocols (RIP - Routing Information Protocol).
 - When graph edges can have negative weights.

 Time Complexity: O(V * E)
 - We iterate over all E edges, V-1 times.
 - An additional O(E) pass to check for negative cycles.
 - Total Time: O(V * E). Slower than Dijkstra, so only use if negative weights exist.

 Space Complexity: O(V)
 - O(V) for the `distances` array.
*/

// Edges represented as [u, v, weight]
func bellmanFord(V: Int, edges: [[Int]], start: Int) -> [Int]? {
    var distances = Array(repeating: Int.max, count: V)
    distances[start] = 0
    
    // Relax all edges V - 1 times
    for _ in 0..<(V - 1) {
        var updated = false
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let weight = edge[2]
            
            if distances[u] != Int.max && distances[u] + weight < distances[v] {
                distances[v] = distances[u] + weight
                updated = true
            }
        }
        // Small optimization: If no distances were updated in an iteration, we can stop early.
        // If it converges early, there are no negative cycles reachable from the source.
        if !updated {
            return distances
        }
    }
    
    // V-th relaxation to detect negative weight cycles
    for edge in edges {
        let u = edge[0]
        let v = edge[1]
        let weight = edge[2]
        
        if distances[u] != Int.max && distances[u] + weight < distances[v] {
            // Negative cycle detected!
            print("Graph contains a negative weight cycle")
            return nil 
        }
    }
    
    return distances
}
