import Foundation

/*
 Disjoint Set (Union-Find)

 Intuition:
 The Disjoint Set is a data structure that keeps track of elements partitioned into a number of disjoint (non-overlapping) subsets.
 It provides near O(1) operations to:
 1. `find(x)`: Determine which subset a particular element is in. Used to check if two elements are in the same subset.
 2. `union(x, y)`: Join two subsets into a single subset.
 
 Optimizations:
 - **Path Compression**: While doing `find`, we make every node on the path point directly to the root. This flattens the tree.
 - **Union by Rank / Size**: When uniting two sets, we attach the smaller tree to the root of the larger tree to keep the tree shallow.

 Usecases & Usage Patterns:
 - Kruskal's algorithm for finding the Minimum Spanning Tree.
 - Cycle detection in undirected graphs.
 - Dynamic connectivity problems (e.g., Leetcode's "Number of Provinces", "Redundant Connection").

 Time Complexity: O(α(V)) for both `find` and `union` operations.
 - α is the Inverse Ackermann function, which grows so slowly it's <= 4 for all practical values of V. Effectively O(1).
 
 Space Complexity: O(V)
 - O(V) to store the `parent` and `rank`/`size` arrays.
*/

class DisjointSet {
    private var parent: [Int]
    private var rank: [Int]
    private var size: [Int]
    
    init(vertices: Int) {
        // 1-based or 0-based indexing support
        parent = Array(0...vertices)
        rank = Array(repeating: 0, count: vertices + 1)
        size = Array(repeating: 1, count: vertices + 1)
    }
    
    // Find with Path Compression
    func find(_ i: Int) -> Int {
        if parent[i] == i {
            return i
        }
        // Path compression: point directly to the root
        parent[i] = find(parent[i])
        return parent[i]
    }
    
    // Union by Rank
    // Trees with smaller height (rank) are attached under the root of the taller tree.
    func unionByRank(_ u: Int, _ v: Int) {
        let rootU = find(u)
        let rootV = find(v)
        
        if rootU == rootV { return }
        
        if rank[rootU] < rank[rootV] {
            parent[rootU] = rootV
        } else if rank[rootV] < rank[rootU] {
            parent[rootV] = rootU
        } else {
            // If ranks are same, pick one as root and increment its rank
            parent[rootV] = rootU
            rank[rootU] += 1
        }
    }
    
    // Union by Size
    // Trees with fewer nodes are attached under the root of the tree with more nodes.
    // Often preferred over rank as it gives the exact size of components easily.
    func unionBySize(_ u: Int, _ v: Int) {
        let rootU = find(u)
        let rootV = find(v)
        
        if rootU == rootV { return }
        
        if size[rootU] < size[rootV] {
            parent[rootU] = rootV
            size[rootV] += size[rootU]
        } else {
            parent[rootV] = rootU
            size[rootU] += size[rootV]
        }
    }
}
