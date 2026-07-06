// 115. Distinct Subsequences
// https://leetcode.com/problems/distinct-subsequences
//
// Intuition/Explanation:
// This is a dynamic programming problem. We want to find how many times `t` appears as a subsequence in `s`.
// Let `dp[j]` be the number of distinct subsequences of `s` (processed so far) that equal `t[0..<j]`.
// We can optimize the standard 2D DP `dp[i][j]` into a 1D array since updating `dp[i][j]` only 
// depends on `dp[i-1][j]` and `dp[i-1][j-1]`.
// For each character in `s`, we iterate through `t` backwards to avoid using the current `s` character multiple times.
// - If `s[i] == t[j]`, then `dp[j] = dp[j] + dp[j-1]`.
//   (We can either include `s[i]` which contributes `dp[j-1]` ways, or exclude it contributing `dp[j]` ways).
// - If `s[i] != t[j]`, `dp[j]` remains unchanged (we can't include `s[i]`).
// Base case: `dp[0] = 1`, because an empty string `t` is a subsequence of `s` in exactly 1 way.
//
// Time Complexity: O(M * N), where M is the length of `s` and N is the length of `t`.
// Space Complexity: O(N), for the 1D DP array of size N + 1.

class Solution {
    func numDistinct(_ s: String, _ t: String) -> Int {
        let sChars = Array(s)
        let tChars = Array(t)
        let m = sChars.count
        let n = tChars.count
        
        if m < n { return 0 }
        
        // dp[j] represents the number of ways to form t[0..<j]
        var dp = Array(repeating: 0, count: n + 1)
        dp[0] = 1 // 1 way to form an empty string
        
        for i in 0..<m {
            // Traverse backwards to use the 1D array effectively 
            // without overwriting values needed for the current step
            if n > 0 {
                for j in (1...n).reversed() {
                    if sChars[i] == tChars[j - 1] {
                        dp[j] += dp[j - 1]
                    }
                }
            }
        }
        
        return dp[n]
    }
}
