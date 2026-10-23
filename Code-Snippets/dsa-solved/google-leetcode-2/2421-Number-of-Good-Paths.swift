// 2421. Number of Good Paths
// https://leetcode.com/problems/number-of-good-paths
//
// Intuition/Explanation:
// A "good path" is a path where the starting node and ending node have the same value `V`, 
// and all nodes in between have values less than or equal to `V`.
// We can process the nodes in increasing order of their values.
// We use a Disjoint Set Union (DSU) / Union-Find data structure to connect components.
// When we process nodes of a certain value `V`, we look at their neighbors. If a neighbor 
// has a value <= `V`, we union the current node and the neighbor, as they can form a valid path.
// After connecting all valid neighbors for a given value `V`, we count how many nodes of value `V` 
// belong to each connected component.
// If a component has `k` nodes with value `V`, the number of good paths between them is `k * (k - 1) / 2`.
// Each node itself is also a good path of length 1, so we also add `k` (or just add 1 per node globally).
//
// Time Complexity: O(N log N), where N is the number of nodes. Sorting the nodes by value takes O(N log N).
// DSU operations take near O(1) time.
// Space Complexity: O(N) to store the DSU structure (parent array) and adjacency list.

class UnionFind {
    var parent: [Int]
    
    init(_ size: Int) {
        parent = Array(0..<size)
    }
    
    func find(_ x: Int) -> Int {
        if parent[x] != x {
            parent[x] = find(parent[x]) // Path compression
        }
        return parent[x]
    }
    
    func union(_ x: Int, _ y: Int) {
        let rootX = find(x)
        let rootY = find(y)
        if rootX != rootY {
            parent[rootX] = rootY
        }
    }
}

// Approach 1: Sorting Edges (Kruskal-like)
class Solution2 {
    func numberOfGoodPaths(_ vals: [Int], _ edges: [[Int]]) -> Int {
        let n = vals.count
        
        // 1. Sort edges based on the maximum value of the two nodes they connect
        let sortedEdges = edges.sorted { edge1, edge2 in
            let max1 = max(vals[edge1[0]], vals[edge1[1]])
            let max2 = max(vals[edge2[0]], vals[edge2[1]])
            return max1 < max2
        }
        
        let dsu = UnionFind(n)
        // Each individual node is a valid good path of length 1, so we start with `n`
        var goodPaths = n 
        
        // `count[i]` will track the number of nodes that share the MAXIMUM value 
        // in the component where `i` is the root.
        var count = Array(repeating: 1, count: n)
        
        // 2 & 3. Iterate through sorted edges and perform unions
        for edge in sortedEdges {
            let u = edge[0]
            let v = edge[1]
            
            let rootU = dsu.find(u)
            let rootV = dsu.find(v)
            
            if rootU != rootV {
                let maxU = vals[rootU]
                let maxV = vals[rootV]
                
                // 4. Count the good paths and dynamically update the root to maintain max values
                if maxU == maxV {
                    // Both components have the same max value.
                    // The number of new paths formed is the product of max value nodes in each component.
                    goodPaths += count[rootU] * count[rootV]
                    
                    // Union and combine the counts
                    dsu.parent[rootU] = rootV 
                    count[rootV] += count[rootU]
                } else if maxU > maxV {
                    // Make rootU the parent of rootV so that the root's value (vals[root]) 
                    // always correctly represents the max value of the component.
                    dsu.parent[rootV] = rootU 
                    // We don't change count[rootU] because the max value nodes from V are smaller
                } else {
                    // Make rootV the parent of rootU
                    dsu.parent[rootU] = rootV
                    // We don't change count[rootV] because the max value nodes from U are smaller
                }
            }
        }
        
        return goodPaths
    }
}


//Approach 2
class Solution {
    func numberOfGoodPaths(_ vals: [Int], _ edges: [[Int]]) -> Int {
        let n = vals.count
        var adj = Array(repeating: [Int](), count: n)
        
        // Build adjacency list
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            adj[u].append(v)
            adj[v].append(u)
        }
        
        // Group nodes by value, using a dictionary to map Value -> [Node Indices]
        var valToNodes = [Int: [Int]]()
        for i in 0..<n {
            valToNodes[vals[i], default: []].append(i)
        }
        
        // Sort unique values
        let sortedVals = valToNodes.keys.sorted()
        
        let dsu = UnionFind(n)
        var goodPaths = 0
        
        // Process nodes in increasing order of their values
        for value in sortedVals {
            let nodes = valToNodes[value]!
            
            // For each node with current `value`, connect it to its neighbors that have <= `value`
            for node in nodes {
                for neighbor in adj[node] {
                    if vals[neighbor] <= value {
                        dsu.union(node, neighbor)
                    }
                }
            }
            
            // Count components for the nodes of the current `value`
            var groupCounts = [Int: Int]()
            for node in nodes {
                let root = dsu.find(node)
                groupCounts[root, default: 0] += 1
            }
            
            // Calculate good paths in each component
            for count in groupCounts.values {
                // Number of pairs is count * (count - 1) / 2
                // Plus the individual nodes themselves (count)
                // Total = count * (count + 1) / 2
                goodPaths += (count * (count + 1)) / 2
            }
        }
        
        return goodPaths
    }
}
