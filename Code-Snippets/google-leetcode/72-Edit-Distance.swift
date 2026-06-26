// 72. Edit Distance
// Link: https://leetcode.com/problems/edit-distance/
//
// Time Complexity: O(M * N), where M and N are the lengths of word1 and word2.
// Explanation: We compute the edit distance for every prefix pair of word1 and word2, taking constant time per pair.
// Space Complexity: O(N), where N is the length of the shorter word.
// Explanation: We optimize the 2D DP table to a 1D array since we only need the previous row's state at any point.

class Solution {
    func minDistance(_ word1: String, _ word2: String) -> Int {
        let chars1 = Array(word1)
        let chars2 = Array(word2)
        
        // Optimization: Ensure word2 is the shorter string to minimize space used
        if chars1.count < chars2.count {
            return minDistance(word2, word1)
        }
        
        let m = chars1.count
        let n = chars2.count
        
        if n == 0 { return m }
        
        // dp array represents the previous row in the theoretical 2D DP matrix
        var dp = Array(0...n)
        
        for i in 1...m {
            // previousDiagonal corresponds to dp[i-1][j-1] in a 2D matrix
            var previousDiagonal = dp[0]
            
            // Base case for empty second word
            dp[0] = i
            
            for j in 1...n {
                // Save current dp[j] (which acts as dp[i-1][j]) before it gets overwritten
                let temp = dp[j]
                
                if chars1[i - 1] == chars2[j - 1] {
                    // Characters match, no new operations needed for this character
                    dp[j] = previousDiagonal
                } else {
                    // Min of replace (previousDiagonal), insert (dp[j - 1]), or delete (dp[j]) + 1 operation
                    dp[j] = min(previousDiagonal, dp[j], dp[j - 1]) + 1
                }
                
                // Update previousDiagonal for the next inner loop iteration
                previousDiagonal = temp
            }
        }
        
        return dp[n]
    }
}
