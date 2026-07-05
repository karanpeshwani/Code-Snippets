import Foundation
import Collections // For Heap

/*
 Dijkstra's Algorithm (Single Source Shortest Path - SSSP)

 Intuition:
 Dijkstra's algorithm finds the shortest path from a starting node to all other nodes in a graph with non-negative edge weights.
 It works greedily using a Min-Heap (Priority Queue). It always picks the unvisited node with the smallest known distance from the start, 
 then updates the distances of its neighbors. Once a node is popped from the min-heap, its shortest distance is finalized.

 Usecases & Usage Patterns:
 - Routing protocols (e.g., OSPF in networks).
 - GPS Navigation systems (finding the quickest route).
 - Pattern: Given a weighted graph, if you need the shortest path from A to B and weights are >= 0, Dijkstra is your go-to.

 Time Complexity: O(E * log(V))
 - Each vertex is extracted from the Priority Queue once taking O(log V) time.
 - For every extracted vertex, we traverse its adjacent edges (total E edges), and push to the priority queue taking O(log V) time.

 Space Complexity: O(V + E)
 - O(V) for the `distances` array.
 - O(V) for the Priority Queue in the worst case (though technically it can grow to O(E) if we don't update keys in place and just push new pairs, but O(V) is the standard bound).
 - O(V + E) for the adjacency list representation.
*/

// Note: swift-collections provides `Heap` which is perfect for Priority Queue.
func dijkstra(V: Int, adj: [[(node: Int, weight: Int)]], start: Int) -> [Int] {
    var distances = Array(repeating: Int.max, count: V)
    distances[start] = 0
    
    // Min-Heap storing tuples of (distance, node)
    // We need to conform to Comparable for Heap to work optimally or use a custom comparator.
    struct EdgeNode: Comparable {
        let distance: Int
        let node: Int
        
        static func < (lhs: EdgeNode, rhs: EdgeNode) -> Bool {
            return lhs.distance < rhs.distance
        }
    }
    
    var minHeap = Heap<EdgeNode>()
    minHeap.insert(EdgeNode(distance: 0, node: start))
    
    while !minHeap.isEmpty {
        let current = minHeap.removeMin()
        let dist = current.distance
        let u = current.node
        
        // If we extracted a stale, longer distance from the heap, ignore it
        if dist > distances[u] { continue }
        
        // Relax edges
        for edge in adj[u] {
            let v = edge.node
            let weight = edge.weight
            
            if distances[u] + weight < distances[v] {
                distances[v] = distances[u] + weight
                minHeap.insert(EdgeNode(distance: distances[v], node: v))
            }
        }
    }
    
    // distances array now holds the shortest path from start to all other nodes
    // Nodes unreachable from start will still have Int.max
    return distances
}
