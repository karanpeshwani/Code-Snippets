import Foundation

/*
 Kruskal's Algorithm (Minimum Spanning Tree)

 Intuition:
 Kruskal's algorithm is another greedy approach to find the MST.
 Instead of starting from a node (like Prim's), we sort ALL edges in ascending order of their weights.
 We then pick edges one by one from the smallest to the largest.
 We include an edge in the MST ONLY if adding it does not form a cycle.
 To efficiently check for cycles, we use the Disjoint Set (Union-Find) data structure.

 Usecases & Usage Patterns:
 - Finding MST in sparse graphs (few edges).
 - Clustering algorithms (Single-linkage clustering).
 
 Time Complexity: O(E * log(E)) + O(E * α(V))
 - Sorting the edges takes O(E log E).
 - For each of the E edges, we use Union-Find operations which take O(α(V)) ~ O(1) amortized time.
 - Total time is bounded by the sorting step: O(E log E). Since E <= V^2, log(E) is at most 2*log(V), so it can also be written as O(E log V).

 Space Complexity: O(V + E)
 - O(E) to store the list of edges for sorting.
 - O(V) for the Disjoint Set data structure (parent and size arrays).
*/

// DisjointSet helper class
class DSU {
    var parent: [Int]
    var size: [Int]
    
    init(_ n: Int) {
        parent = Array(0..<n)
        size = Array(repeating: 1, count: n)
    }
    
    func find(_ i: Int) -> Int {
        if parent[i] == i { return i }
        parent[i] = find(parent[i])
        return parent[i]
    }
    
    func union(_ u: Int, _ v: Int) {
        let rootU = find(u)
        let rootV = find(v)
        if rootU != rootV {
            if size[rootU] < size[rootV] {
                parent[rootU] = rootV
                size[rootV] += size[rootU]
            } else {
                parent[rootV] = rootU
                size[rootU] += size[rootV]
            }
        }
    }
}

func kruskalsAlgorithm(V: Int, edges: [[Int]]) -> Int {
    // edges: [u, v, weight]
    
    // 1. Sort edges by weight
    let sortedEdges = edges.sorted { $0[2] < $1[2] }
    
    let dsu = DSU(V)
    var mstWeight = 0
    var edgesCount = 0
    
    // 2. Iterate through sorted edges and pick non-cycle forming edges
    for edge in sortedEdges {
        let u = edge[0]
        let v = edge[1]
        let weight = edge[2]
        
        // If they don't share the same root, no cycle will be formed
        if dsu.find(u) != dsu.find(v) {
            dsu.union(u, v)
            mstWeight += weight
            edgesCount += 1
            
            // Early exit if we've included V-1 edges
            if edgesCount == V - 1 { break }
        }
    }
    
    return mstWeight
}
