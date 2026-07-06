// 741. Cherry Pickup
// https://leetcode.com/problems/cherry-pickup

/*
 Intuition:
 Instead of having one person go from (0,0) to (N-1,N-1) and then back, it is mathematically
 equivalent to having two people start at (0,0) and go to (N-1,N-1) simultaneously.
 Let the two people be at (r1, c1) and (r2, c2). Since they move one step (right or down) at a time,
 they will always have taken the same number of steps: `r1 + c1 = r2 + c2 = step`.
 So, we can represent the state using just `step, r1, r2`. 
 Then `c1 = step - r1` and `c2 = step - r2`.
 We use Dynamic Programming to maximize the cherries picked. If both are at the same cell,
 the cherry is only picked once.

 Time Complexity: O(N^3)
 - The state space is bounded by the number of steps (2N-1) and the rows (N for r1, N for r2).
 - We have O(N) steps and O(N^2) combinations of r1 and r2 per step.
 - Overall time complexity is O(N^3).

 Space Complexity: O(N^2)
 - We can optimize space by only keeping the DP table for the current step and the previous step.
 - The DP table for a single step is of size N x N.
 - Overall space complexity is O(N^2).
 */

class Solution {
    func cherryPickup(_ grid: [[Int]]) -> Int {
        let n = grid.count
        
        // DP table for the current step. dp[r1][r2]
        // Initialize with a very small number representing -infinity
        var dp = Array(repeating: Array(repeating: -1, count: n), count: n)
        dp[0][0] = grid[0][0]
        
        let maxSteps = 2 * n - 2
        
        for step in 1...maxSteps {
            var nextDp = Array(repeating: Array(repeating: -1, count: n), count: n)
            
            for r1 in 0..<n {
                for r2 in 0..<n {
                    let c1 = step - r1
                    let c2 = step - r2
                    
                    // Check if within bounds and not a thorn (-1)
                    if c1 < 0 || c1 >= n || c2 < 0 || c2 >= n || grid[r1][c1] == -1 || grid[r2][c2] == -1 {
                        continue
                    }
                    
                    // We need to find the max from the previous step
                    // Possible previous moves: (right, right), (down, down), (right, down), (down, right)
                    var maxPrev = -1
                    
                    // r1-1, r2-1 (down, down)
                    if r1 > 0 && r2 > 0 { maxPrev = max(maxPrev, dp[r1-1][r2-1]) }
                    // r1-1, r2 (down, right)
                    if r1 > 0 { maxPrev = max(maxPrev, dp[r1-1][r2]) }
                    // r1, r2-1 (right, down)
                    if r2 > 0 { maxPrev = max(maxPrev, dp[r1][r2-1]) }
                    // r1, r2 (right, right)
                    maxPrev = max(maxPrev, dp[r1][r2])
                    
                    if maxPrev != -1 {
                        var cherries = maxPrev
                        cherries += grid[r1][c1]
                        if r1 != r2 {
                            // If they are not on the same cell, add cherry from person 2
                            cherries += grid[r2][c2]
                        }
                        nextDp[r1][r2] = cherries
                    }
                }
            }
            dp = nextDp
        }
        
        return max(0, dp[n-1][n-1])
    }
}
