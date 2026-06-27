// 1857. Largest Color Value in a Directed Graph
// https://leetcode.com/problems/largest-color-value-in-a-directed-graph
//
// Time Complexity: O(V + E), where V is the number of nodes and E is the number of edges.
// We visit each node and each edge once during the topological sort. For each node, we do O(26) work 
// to update the DP state of its neighbors, which is effectively O(1). Thus, the time complexity is linear.
// Space Complexity: O(V + E) for storing the adjacency list and in-degrees. The DP array takes O(V * 26) = O(V) space.

class Solution {
    func largestPathValue(_ colors: String, _ edges: [[Int]]) -> Int {
        let n = colors.count
        let colorArray = Array(colors).map { Int($0.asciiValue! - Character("a").asciiValue!) }
        
        var adj = [[Int]](repeating: [], count: n)
        var inDegree = [Int](repeating: 0, count: n)
        
        // Build the graph
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            adj[u].append(v)
            inDegree[v] += 1
        }
        
        // dp[u][c] stores the max frequency of color c in a valid path ending at node u
        var dp = [[Int]](repeating: [Int](repeating: 0, count: 26), count: n)
        
        var queue = [Int]()
        
        // Enqueue nodes with in-degree 0
        for i in 0..<n {
            if inDegree[i] == 0 {
                queue.append(i)
            }
        }
        
        var visitedCount = 0
        var maxColorValue = 0
        
        // Kahn's Algorithm for Topological Sorting
        var head = 0
        while head < queue.count {
            let u = queue[head]
            head += 1
            visitedCount += 1
            
            // Add the node's own color to its DP state
            let c = colorArray[u]
            dp[u][c] += 1
            
            // Update the global maximum color value
            for i in 0..<26 {
                if dp[u][i] > maxColorValue {
                    maxColorValue = dp[u][i]
                }
            }
            
            // Propagate the DP state to neighbors
            for v in adj[u] {
                for i in 0..<26 {
                    if dp[u][i] > dp[v][i] {
                        dp[v][i] = dp[u][i]
                    }
                }
                
                inDegree[v] -= 1
                if inDegree[v] == 0 {
                    queue.append(v)
                }
            }
        }
        
        // If there's a cycle, we won't be able to visit all nodes
        if visitedCount < n {
            return -1
        }
        
        return maxColorValue
    }
}
