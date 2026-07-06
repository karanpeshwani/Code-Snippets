// 10. Regular Expression Matching
// https://leetcode.com/problems/regular-expression-matching
//
// Intuition/Explanation:
// We can use dynamic programming to solve this. Let `dp[i][j]` be a boolean indicating 
// whether the first `i` characters of `s` match the first `j` characters of `p`.
// If `p[j-1] == '*'`:
//  - We can ignore the '*' and the preceding character: `dp[i][j] = dp[i][j-2]`
//  - Or, if the preceding character matches `s[i-1]` (i.e. `p[j-2] == s[i-1]` or `p[j-2] == '.'`), 
//    we can use the '*' to match `s[i-1]`: `dp[i][j] = dp[i-1][j]`
// If `p[j-1] != '*'`:
//  - We must have `p[j-1] == s[i-1]` or `p[j-1] == '.'` for a match: `dp[i][j] = dp[i-1][j-1]`
// Base cases: `dp[0][0] = true`, and for `j > 0`, `dp[0][j] = dp[0][j-2]` if `p[j-1] == '*'`.
//
// Time Complexity: O(M * N), where M is the length of s and N is the length of p. 
// We iterate through the DP table of size (M+1) x (N+1).
// Space Complexity: O(M * N) for the DP table. (This can be optimized to O(N) by just keeping the previous row).

class Solution {
    func isMatch(_ s: String, _ p: String) -> Bool {
        let sChars = Array(s)
        let pChars = Array(p)
        let m = sChars.count
        let n = pChars.count
        
        // dp[i][j] represents if s[0..<i] matches p[0..<j]
        var dp = Array(repeating: Array(repeating: false, count: n + 1), count: m + 1)
        
        // Empty string matches empty pattern
        dp[0][0] = true
        
        // Deal with patterns like a*, a*b*, a*b*c* which can match an empty string
        for j in 1...n {
            if pChars[j - 1] == "*" {
                dp[0][j] = dp[0][j - 2]
            }
        }
        
        // Fill the DP table
        if m > 0 {
            for i in 1...m {
                if n > 0 {
                    for j in 1...n {
                        if pChars[j - 1] == "*" {
                            // 1. Ignore the preceding character and '*' (0 occurrences)
                            // 2. Or if preceding character matches current s character, 
                            //    we can use '*' to match (1 or more occurrences)
                            let prevCharMatches = pChars[j - 2] == sChars[i - 1] || pChars[j - 2] == "."
                            dp[i][j] = dp[i][j - 2] || (prevCharMatches && dp[i - 1][j])
                        } else {
                            // Single character match
                            let charMatches = pChars[j - 1] == sChars[i - 1] || pChars[j - 1] == "."
                            dp[i][j] = charMatches && dp[i - 1][j - 1]
                        }
                    }
                }
            }
        }
        
        return dp[m][n]
    }
}
