// 847. Shortest Path Visiting All Nodes
// https://leetcode.com/problems/shortest-path-visiting-all-nodes/

/*
 Intuition:
 We need to find the shortest path that visits all nodes in an undirected graph. 
 Since we need the shortest path and all edges have equal weight (1), Breadth-First Search (BFS) is optimal.
 Because we are allowed to revisit nodes and traverse edges multiple times, a simple `visited` array is not enough.
 We need our state to be `(currentNode, visitedNodesMask)`. A bitmask is perfect for `visitedNodesMask` 
 since the number of nodes N is small (N <= 12).
 We start the BFS simultaneously from all nodes with distance 0 and mask `1 << startNode`.
 The BFS explores level by level. The first time we reach a state where the `visitedNodesMask` has all 
 N bits set to 1, we have found the shortest path.

 Time Complexity: O(N * 2^N)
 - There are N possible nodes and 2^N possible visited masks, resulting in N * 2^N unique states.
 - In the worst case, we visit every state once. From each state, we can transition to at most N neighbors.
 - Total time complexity is bounded by O(N * 2^N).

 Space Complexity: O(N * 2^N)
 - We use a queue for BFS and a set (or 2D boolean array) to keep track of visited states.
 - Both can hold up to N * 2^N elements.
 - Overall space complexity is O(N * 2^N).
 */

import Collections

class Solution {
    struct State: Hashable {
        let node: Int
        let mask: Int
    }
    
    func shortestPathLength(_ graph: [[Int]]) -> Int {
        let n = graph.count
        if n <= 1 { return 0 }
        
        let targetMask = (1 << n) - 1
        var queue = Deque<(state: State, dist: Int)>()
        var visited = Set<State>()
        
        // Start BFS from all nodes
        for i in 0..<n {
            let initialState = State(node: i, mask: 1 << i)
            queue.append((initialState, 0))
            visited.insert(initialState)
        }
        
        while !queue.isEmpty {
            let (currentState, currentDist) = queue.removeFirst()
            
            // If all nodes are visited, return the distance
            if currentState.mask == targetMask {
                return currentDist
            }
            
            // Explore neighbors
            for neighbor in graph[currentState.node] {
                let nextMask = currentState.mask | (1 << neighbor)
                let nextState = State(node: neighbor, mask: nextMask)
                
                if !visited.contains(nextState) {
                    visited.insert(nextState)
                    queue.append((nextState, currentDist + 1))
                }
            }
        }
        
        return -1
    }
}
