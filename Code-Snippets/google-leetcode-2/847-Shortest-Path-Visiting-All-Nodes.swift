// 847. Shortest Path Visiting All Nodes
// https://leetcode.com/problems/shortest-path-visiting-all-nodes

/*
 Intuition:
 The problem asks for the shortest path to visit every node, and we can start anywhere and revisit nodes.
 Because we want the *shortest* path in an unweighted graph, Breadth-First Search (BFS) is ideal.
 The state in our BFS must capture not just the current node, but also the set of nodes visited so far.
 Since the number of nodes N is very small (N <= 12), we can use a bitmask to represent the visited nodes.
 State: `(currentNode, visitedMask)`.
 We start by enqueuing all nodes with their respective initial masks, because any node can be the start.
 The target is to reach a `visitedMask` where all N bits are set, i.e., `(1 << N) - 1`.

 Time Complexity: O(N * 2^N)
 - There are N nodes and 2^N possible masks, meaning there are N * 2^N possible states.
 - From each state, we can transition to at most N neighbors.
 - In BFS, each state is processed at most once, taking O(N * 2^N) time.

 Space Complexity: O(N * 2^N)
 - The queue can hold up to O(N * 2^N) states.
 - A visited set/array to keep track of seen states takes O(N * 2^N) space.
 - Overall space complexity is O(N * 2^N).
 */

class Solution {
    func shortestPathLength(_ graph: [[Int]]) -> Int {
        let n = graph.count
        if n == 1 { return 0 }
        
        let targetMask = (1 << n) - 1
        var queue = [(node: Int, mask: Int, dist: Int)]()
        
        // visited[node][mask]
        var visited = Array(repeating: Array(repeating: false, count: 1 << n), count: n)
        
        // Enqueue all starting nodes
        for i in 0..<n {
            let mask = 1 << i
            queue.append((node: i, mask: mask, dist: 0))
            visited[i][mask] = true
        }
        
        var head = 0
        while head < queue.count {
            let current = queue[head]
            head += 1
            
            // Check all neighbors
            for neighbor in graph[current.node] {
                let newMask = current.mask | (1 << neighbor)
                
                // If we reach the target mask, return the distance + 1
                if newMask == targetMask {
                    return current.dist + 1
                }
                
                // If this state has not been visited, enqueue it
                if !visited[neighbor][newMask] {
                    visited[neighbor][newMask] = true
                    queue.append((node: neighbor, mask: newMask, dist: current.dist + 1))
                }
            }
        }
        
        return 0
    }
}
