// 312. Burst Balloons
// Link: https://leetcode.com/problems/burst-balloons/
//
// Time Complexity: O(N^3), where N is the number of balloons.
// Explanation: The dynamic programming table has N^2 states, and for each state, we iterate through up to N possible balloons to burst last.
// Space Complexity: O(N^2)
// Explanation: The DP table stores the maximum coins for every possible subarray of balloons.

class Solution {
    func maxCoins(_ nums: [Int]) -> Int {
        // Pad the array with 1s to handle the boundaries gracefully
        var balloons = [1]
        balloons.append(contentsOf: nums)
        balloons.append(1)
        
        let n = balloons.count
        // dp[i][j] represents the max coins obtained by bursting balloons strictly between indices i and j
        var dp = Array(repeating: Array(repeating: 0, count: n), count: n)
        
        // len is the length of the subarray we are currently considering
        for len in 2..<n {
            for left in 0..<(n - len) {
                let right = left + len
                
                // i is the balloon we choose to burst LAST in the range (left, right)
                for i in (left + 1)..<right {
                    let coins = balloons[left] * balloons[i] * balloons[right]
                    dp[left][right] = max(dp[left][right], coins + dp[left][i] + dp[i][right])
                }
            }
        }
        
        return dp[0][n - 1]
    }
}
