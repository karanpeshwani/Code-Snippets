//Again
// 1857. Largest Color Value in a Directed Graph
// https://leetcode.com/problems/largest-color-value-in-a-directed-graph
//
// Time Complexity: O(V + E), where V is the number of nodes and E is the number of edges.
// We visit each node and each edge once during the topological sort. For each node, we do O(26) work 
// to update the DP state of its neighbors, which is effectively O(1). Thus, the time complexity is linear.
// Space Complexity: O(V + E) for storing the adjacency list and in-degrees. The DP array takes O(V * 26) = O(V) space.

//Approach 1: DFS:
class Solution {

    private var nodeColorMaxFreq: [[Int]?] = [] // Memo: Max color freqs per node
    private var n: Int = 0
    private var graph: [[Int]] = []             // Adjacency list
    private var indegree: [Int] = []            // Incoming edge count
    private var colors: [Character] = []        // Node colors array

    private func DFS(_ currentNode: Int, _ visited: inout [Bool]) -> Bool {
        if visited[currentNode] { return true } // Cycle detected (back-edge)

        if nodeColorMaxFreq[currentNode] != nil { return false } // Already processed

        visited[currentNode] = true
        nodeColorMaxFreq[currentNode] = Array(repeating: 0, count: 26)

        for neigh in graph[currentNode] {
            if DFS(neigh, &visited) { return true } // Propagate cycle up

            // DP: Accumulate max color frequencies from downstream paths
            for i in 0..<26 {
                nodeColorMaxFreq[currentNode]![i] = max(
                    nodeColorMaxFreq[currentNode]![i], 
                    nodeColorMaxFreq[neigh]![i]
                )
            }
        }

        visited[currentNode] = false // Backtrack recursion stack

        // Add current node's color to its own frequency tally
        let currentCharIndex = Int(colors[currentNode].asciiValue! - Character("a").asciiValue!)
        nodeColorMaxFreq[currentNode]![currentCharIndex] += 1

        return false
    }

    func largestPathValue(_ colors: String, _ edges: [[Int]]) -> Int {
        self.n = colors.count
        self.colors = Array(colors)
        self.nodeColorMaxFreq = Array(repeating: nil, count: n)
        self.indegree = Array(repeating: 0, count: n)
        self.graph = Array(repeating: [], count: n)

        // 1. Build graph & calculate indegrees
        for edge in edges {
            graph[edge[0]].append(edge[1])
            indegree[edge[1]] += 1
        }

        var result: Int = 1

        // 2. DFS from valid starting points (indegree == 0)
        for i in 0..<n {
            if indegree[i] == 0 {
                var visited: [Bool] = Array(repeating: false, count: n)
                
                if DFS(i, &visited) { return -1 } // Graph has a cycle

                // Update global max with results from this path
                for freq in nodeColorMaxFreq[i]! {
                    result = max(result, freq)
                }
            }
        }

        // 3. Catch isolated cycles (nodes that were never reached)
        for element in nodeColorMaxFreq {
            guard let element else { return -1 }
        }

        return result
    }
}





//Approach 2:
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
