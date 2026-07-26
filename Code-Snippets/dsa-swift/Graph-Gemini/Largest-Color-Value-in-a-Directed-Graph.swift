/* ==========================================
 Largest Color Value in a Directed Graph
 ==========================================
 
 Question:
 There is a directed graph of n colored nodes and m edges. The nodes are numbered from 0 to n - 1.
 You are given a string colors where colors[i] is a lowercase English letter representing the color 
 of the ith node in this graph (0-indexed). You are also given a 2D array edges where 
 edges[j] = [aj, bj] indicates that there is a directed edge from node aj to node bj.
 A valid path in the graph is a sequence of nodes x1 -> x2 -> x3 -> ... -> xk such that there is 
 a directed edge from xi to xi+1 for every 1 <= i < k. The color value of the path is the number 
 of nodes that are colored the most frequently occurring color along that path.
 Return the largest color value of any valid path in the given graph, or -1 if the graph contains a cycle.
 
 Intuition/Explanation:
 This problem asks for the maximum frequency of any color along any path in a Directed Acyclic Graph (DAG).
 If there's a cycle, we must return -1.
 We can use Topological Sort (Kahn's Algorithm) to process the graph. As we process nodes in topological 
 order, we can use Dynamic Programming to maintain the maximum count of each color up to that node.
 Let `dp[u][c]` be the maximum count of color `c` in any path ending at node `u`.
 For each neighbor `v` of `u`, `dp[v][c] = max(dp[v][c], dp[u][c] + (color[v] == c ? 1 : 0))`.
 By counting the number of visited nodes during Kahn's algorithm, we can detect if a cycle exists 
 (if visited count < total nodes, return -1).
 
 Time Complexity: O(V + E) where V is the number of nodes, and E is edges, tracking 26 colors per node.
 Space Complexity: O(V + E + 26 * V) for the graph and DP table.
*/

class SolutionLargestColorValue {
    func largestPathValue(_ colors: String, _ edges: [[Int]]) -> Int {
        let n = colors.count
        let colorArray = Array(colors)
        var adj = Array(repeating: [Int](), count: n)
        var inDegree = Array(repeating: 0, count: n)
        
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            adj[u].append(v)
            inDegree[v] += 1
        }
        
        var queue = [Int]()
        // dp[i][c] stores the max count of color 'c' on a path ending at node 'i'
        var dp = Array(repeating: Array(repeating: 0, count: 26), count: n)
        
        for i in 0..<n {
            if inDegree[i] == 0 {
                queue.append(i)
                let colorIdx = Int(colorArray[i].asciiValue! - Character("a").asciiValue!)
                dp[i][colorIdx] = 1
            }
        }
        
        var visitedCount = 0
        var maxColorValue = 0
        
        while !queue.isEmpty {
            let u = queue.removeFirst()
            visitedCount += 1
            
            let currentColorIdx = Int(colorArray[u].asciiValue! - Character("a").asciiValue!)
            
            // Find the max value ending at u
            for c in 0..<26 {
                maxColorValue = max(maxColorValue, dp[u][c])
            }
            
            for v in adj[u] {
                let vColorIdx = Int(colorArray[v].asciiValue! - Character("a").asciiValue!)
                for c in 0..<26 {
                    let additional = (c == vColorIdx) ? 1 : 0
                    dp[v][c] = max(dp[v][c], dp[u][c] + additional)
                }
                
                inDegree[v] -= 1
                if inDegree[v] == 0 {
                    queue.append(v)
                }
            }
        }
        
        return visitedCount == n ? maxColorValue : -1
    }
}
