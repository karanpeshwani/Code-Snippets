// 685. Redundant Connection II
// https://leetcode.com/problems/redundant-connection-ii
// Time Complexity: O(N * α(N)) ≈ O(N), where N is the number of nodes (and edges). 
// The Union-Find operations take nearly constant time with path compression.
// Space Complexity: O(N), for the parent arrays used in tracking indegrees and Union-Find.

class Solution {
    func findRedundantDirectedConnection(_ edges: [[Int]]) -> [Int] {
        let n = edges.count
        var parent = [Int](repeating: 0, count: n + 1)
        
        var edge1: [Int]? = nil
        var edge2: [Int]? = nil
        
        // Find if any node has two parents (indegree 2)
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            if parent[v] > 0 {
                // v already has a parent, so we found the two edges causing indegree 2
                edge1 = [parent[v], v]
                edge2 = edge
            } else {
                parent[v] = u
            }
        }
        
        // Union-Find structure
        var ufParent = Array(0...n)
        
        func find(_ i: Int) -> Int {
            if ufParent[i] == i {
                return i
            }
            // Path compression
            ufParent[i] = find(ufParent[i])
            return ufParent[i]
        }
        
        func union(_ i: Int, _ j: Int) -> Bool {
            let rootI = find(i)
            let rootJ = find(j)
            if rootI == rootJ {
                return false // Cycle detected
            }
            ufParent[rootI] = rootJ
            return true
        }
        
        // Process edges to detect cycles, skipping edge2 if it exists
        for edge in edges {
            if let e2 = edge2, edge == e2 {
                continue // Skip the tentatively redundant edge
            }
            
            let u = edge[0]
            let v = edge[1]
            
            if !union(u, v) {
                // Cycle found
                if edge1 != nil {
                    // If there was a node with indegree 2, and skipping edge2 didn't fix the cycle,
                    // it means edge1 is part of the cycle and is the redundant one.
                    return edge1!
                } else {
                    // No node has indegree 2, so the graph is just a cycle. 
                    // The edge that caused the cycle is the redundant one.
                    return edge
                }
            }
        }
        
        // If skipping edge2 fixed all issues (no cycle found), then edge2 is the redundant one.
        return edge2!
    }
}
