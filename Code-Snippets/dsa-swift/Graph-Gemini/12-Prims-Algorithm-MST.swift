import Foundation
import Collections // For Heap

/*
 Prim's Algorithm (Minimum Spanning Tree)

 Intuition:
 A Minimum Spanning Tree (MST) is a subset of edges that connects all vertices together, without any cycles, and with the minimum possible total edge weight.
 Prim's algorithm builds the MST greedily. It starts from an arbitrary node, marks it as part of the MST, 
 and uses a Min-Heap to continually pick the smallest edge that connects a node *inside* the MST to a node *outside* the MST.

 Usecases & Usage Patterns:
 - Network design (laying cables, designing water supply networks).
 - Approximation algorithms for NP-hard problems (like the Traveling Salesperson Problem).
 - Use Prim's over Kruskal's for dense graphs (many edges).

 Time Complexity: O(E * log(V))
 - We use a Priority Queue. Extracting the minimum takes O(log V). We might do this for every edge, so O(E log V).

 Space Complexity: O(V + E)
 - O(V) for the `inMST` array to track visited nodes.
 - O(E) for the priority queue in the worst case (number of edges stored).
*/

func primsAlgorithm(V: Int, adj: [[(node: Int, weight: Int)]]) -> Int {
    var inMST = Array(repeating: false, count: V)
    
    struct Edge: Comparable {
        let weight: Int
        let node: Int
        
        static func < (lhs: Edge, rhs: Edge) -> Bool {
            return lhs.weight < rhs.weight
        }
    }
    
    var minHeap = Heap<Edge>()
    // Start from node 0 (can be any node)
    minHeap.insert(Edge(weight: 0, node: 0))
    
    var sumOfMST = 0
    var edgesCount = 0
    
    while !minHeap.isEmpty && edgesCount < V {
        let current = minHeap.removeMin()
        let u = current.node
        let wt = current.weight
        
        // If already in MST, skip
        if inMST[u] { continue }
        
        // Include in MST
        inMST[u] = true
        sumOfMST += wt
        edgesCount += 1
        
        for neighbor in adj[u] {
            let v = neighbor.node
            let edgeWeight = neighbor.weight
            
            // If the neighbor is not yet in the MST, push the edge to the heap
            if !inMST[v] {
                minHeap.insert(Edge(weight: edgeWeight, node: v))
            }
        }
    }
    
    return sumOfMST
}
