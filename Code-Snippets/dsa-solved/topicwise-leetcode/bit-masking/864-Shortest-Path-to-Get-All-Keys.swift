// 864. Shortest Path to Get All Keys
// https://leetcode.com/problems/shortest-path-to-get-all-keys/

/*
 Intuition:
 We need to find the shortest path to collect all keys in a 2D grid. The shortest path on an unweighted grid implies Breadth-First Search (BFS).
 However, we can walk on the same cell multiple times (e.g., walk back after getting a key). 
 Thus, the state must include what keys we currently hold: `(row, col, keysMask)`.
 Since there are at most 6 keys ('a' to 'f'), a bitmask is perfect for `keysMask`.
 We first scan the grid to find the starting position ('@') and the total number of keys.
 Then we start a BFS. If we step on a key, we add it to our bitmask. If we step on a lock, we can only pass
 if the corresponding bit is set in our bitmask. We reach the goal when our `keysMask` equals `(1 << totalKeys) - 1`.

 Time Complexity: O(M * N * 2^K)
 - Let M and N be the dimensions of the grid, and K be the total number of keys.
 - There are M * N * 2^K possible unique states.
 - In the worst case, BFS will visit every state once.
 - Total time complexity is O(M * N * 2^K).

 Space Complexity: O(M * N * 2^K)
 - We use a queue for BFS and a 3D visited array (or set) to track visited states.
 - Both can store up to M * N * 2^K elements.
 - Overall space complexity is O(M * N * 2^K).
 */

import Collections

class Solution {
    struct State: Hashable {
        let r: Int
        let c: Int
        let mask: Int
    }
    
    func shortestPathAllKeys(_ grid: [String]) -> Int {
        let m = grid.count
        let n = grid[0].count
        var gridChars = [[Character]]()
        
        var startR = -1
        var startC = -1
        var totalKeys = 0
        
        // Parse the grid, find start and count keys
        for (i, row) in grid.enumerated() {
            let chars = Array(row)
            gridChars.append(chars)
            for j in 0..<n {
                let char = chars[j]
                if char == "@" {
                    startR = i
                    startC = j
                } else if char >= "a" && char <= "f" {
                    totalKeys += 1
                }
            }
        }
        
        let targetMask = (1 << totalKeys) - 1
        var queue = Deque<(state: State, dist: Int)>()
        var visited = Set<State>()
        
        let initialState = State(r: startR, c: startC, mask: 0)
        queue.append((initialState, 0))
        visited.insert(initialState)
        
        let dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        
        while !queue.isEmpty {
            let (currState, dist) = queue.removeFirst()
            
            if currState.mask == targetMask {
                return dist
            }
            
            for dir in dirs {
                let nextR = currState.r + dir.0
                let nextC = currState.c + dir.1
                
                // Check bounds
                if nextR >= 0 && nextR < m && nextC >= 0 && nextC < n {
                    let nextChar = gridChars[nextR][nextC]
                    
                    // Cannot pass through walls
                    if nextChar == "#" { continue }
                    
                    // If it's a lock, check if we have the key
                    if nextChar >= "A" && nextChar <= "F" {
                        let keyIndex = Int(nextChar.asciiValue! - Character("A").asciiValue!)
                        if (currState.mask & (1 << keyIndex)) == 0 {
                            continue // Don't have the key
                        }
                    }
                    
                    var nextMask = currState.mask
                    // If it's a key, pick it up
                    if nextChar >= "a" && nextChar <= "f" {
                        let keyIndex = Int(nextChar.asciiValue! - Character("a").asciiValue!)
                        nextMask |= (1 << keyIndex)
                    }
                    
                    let nextState = State(r: nextR, c: nextC, mask: nextMask)
                    if !visited.contains(nextState) {
                        visited.insert(nextState)
                        queue.append((nextState, dist + 1))
                    }
                }
            }
        }
        
        return -1
    }
}
