// 1639. Number of Ways to Form a Target String Given a Dictionary
// https://leetcode.com/problems/number-of-ways-to-form-a-target-string-given-a-dictionary
//
// Time Complexity: O(N * W + W * T), where N is the number of words, W is the length of each word, 
// and T is the length of the target string. 
// We first build a frequency table for each column across all words in O(N * W) time.
// Then, we use a DP approach iterating over the columns (W) and the target string length (T) in O(W * T) time.
// Space Complexity: O(W * 26 + T) = O(W + T). The frequency table takes O(W * 26) space. 
// The DP array takes O(T) space.

class Solution {
    func numWays(_ words: [String], _ target: String) -> Int {
        let mod = 1_000_000_007
        let wLength = words[0].count
        let tLength = target.count
        
        if wLength < tLength {
            return 0
        }
        
        // freq[k][c] will store the frequency of character c at index k across all words
        var freq = [[Int]](repeating: [Int](repeating: 0, count: 26), count: wLength)
        
        // Convert words to array of characters for fast indexing
        for word in words {
            let chars = Array(word)
            for k in 0..<wLength {
                let charIndex = Int(chars[k].asciiValue! - Character("a").asciiValue!)
                freq[k][charIndex] += 1
            }
        }
        
        let targetChars = Array(target)
        
        // dp[i] will store the number of ways to form a prefix of the target of length i
        var dp = [Int](repeating: 0, count: tLength + 1)
        dp[0] = 1 // 1 way to form an empty string
        
        // Iterate through each column in the words
        for k in 0..<wLength {
            // Iterate backwards through the target string to use DP array in-place
            // We only need to check up to min(k + 1, tLength) because we can't form a target prefix longer than available columns
            for i in stride(from: min(k + 1, tLength), through: 1, by: -1) {
                let charIndex = Int(targetChars[i - 1].asciiValue! - Character("a").asciiValue!)
                let count = freq[k][charIndex]
                
                if count > 0 {
                    dp[i] = (dp[i] + dp[i - 1] * count) % mod
                }
            }
        }
        
        return dp[tLength]
    }
}
