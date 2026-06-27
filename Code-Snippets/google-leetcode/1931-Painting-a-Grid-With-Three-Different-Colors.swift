// 1931-Painting-a-Grid-With-Three-Different-Colors.swift
// 1931. Painting a Grid With Three Different Colors
// https://leetcode.com/problems/painting-a-grid-with-three-different-colors/
//
// Time Complexity: O(N * 3^M). M is at most 5, so 3^M is small. We precompute valid states and transitions, then run a DP.
// Space Complexity: O(3^M) for storing the DP table and adjacency lists.

class Solution {
    func colorTheGrid(_ m: Int, _ n: Int) -> Int {
        let mod = 1_000_000_007
        
        // A state can be represented as an array of colors.
        // Generate all valid single column states.
        var validStates = [[Int]]()
        func dfs(_ row: Int, _ currState: [Int]) {
            if row == m {
                validStates.append(currState)
                return
            }
            for color in 0..<3 {
                if row == 0 || currState[row - 1] != color {
                    dfs(row + 1, currState + [color])
                }
            }
        }
        dfs(0, [])
        
        // Find which states can be adjacent to each other
        var adj = [Int: [Int]]()
        for i in 0..<validStates.count {
            for j in 0..<validStates.count {
                var canBeAdjacent = true
                for r in 0..<m {
                    if validStates[i][r] == validStates[j][r] {
                        canBeAdjacent = false
                        break
                    }
                }
                if canBeAdjacent {
                    adj[i, default: []].append(j)
                }
            }
        }
        
        // DP: dp[i] is the number of ways to color the grid ending with validStates[i]
        var dp = Array(repeating: 1, count: validStates.count)
        
        for _ in 1..<n {
            var nextDp = Array(repeating: 0, count: validStates.count)
            for i in 0..<validStates.count {
                for nextState in adj[i, default: []] {
                    nextDp[nextState] = (nextDp[nextState] + dp[i]) % mod
                }
            }
            dp = nextDp
        }
        
        var res = 0
        for ways in dp {
            res = (res + ways) % mod
        }
        return res
    }
}
