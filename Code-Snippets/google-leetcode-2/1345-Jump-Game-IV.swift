// 1345. Jump Game IV
// https://leetcode.com/problems/jump-game-iv

/*
 Intuition:
 We need to find the minimum number of jumps to reach the last index.
 The available moves from index `i` are `i - 1`, `i + 1`, and any index `j` where `arr[i] == arr[j]`.
 Since we are looking for the shortest path in an unweighted graph, Breadth-First Search (BFS) is the
 optimal approach.
 To handle the jump to identical values efficiently, we can precompute a hash map mapping each value
 to a list of its indices.
 A critical optimization: once we jump to a group of identical values, we must clear that value's
 list from the hash map. If we don't, we might iterate over the same list of indices multiple times,
 which would degrade the time complexity to O(N^2) in the worst case (e.g., an array of all same elements).

 Time Complexity: O(N)
 - The BFS visits each index at most once.
 - Each edge is traversed a constant number of times because we clear the hash map entry after the first use.
 - Overall time complexity is strictly O(N).

 Space Complexity: O(N)
 - The hash map stores a list of indices for each unique value, taking O(N) space.
 - The BFS queue and the visited set take O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    func minJumps(_ arr: [Int]) -> Int {
        let n = arr.count
        if n <= 1 { return 0 }
        
        // valueToIndices maps a value to all indices where it appears
        var valueToIndices = [Int: [Int]]()
        for i in 0..<n {
            valueToIndices[arr[i], default: []].append(i)
        }
        
        var queue = [0]
        var visited = Array(repeating: false, count: n)
        visited[0] = true
        var steps = 0
        
        while !queue.isEmpty {
            let size = queue.count
            var nextQueue = [Int]()
            
            for _ in 0..<size {
                let curr = queue.removeFirst()
                
                // If we reached the last index
                if curr == n - 1 {
                    return steps
                }
                
                // Check neighbors: i - 1, i + 1, and same values
                var neighbors = [Int]()
                
                // Add identical value indices
                if let indices = valueToIndices[arr[curr]] {
                    neighbors.append(contentsOf: indices)
                    // CRITICAL: clear the list to avoid O(N^2) complexity
                    valueToIndices[arr[curr]] = nil
                }
                
                // Add adjacent indices
                neighbors.append(curr + 1)
                neighbors.append(curr - 1)
                
                for neighbor in neighbors {
                    if neighbor >= 0 && neighbor < n && !visited[neighbor] {
                        visited[neighbor] = true
                        nextQueue.append(neighbor)
                    }
                }
            }
            queue = nextQueue
            steps += 1
        }
        
        return 0
    }
}
