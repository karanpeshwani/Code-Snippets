// 87. Scramble String
// https://leetcode.com/problems/scramble-string

/*
 Intuition/Explanation:
 We use recursion with memoization. 
 A string `s1` is a scrambled string of `s2` if they are equal, or if we can split both 
 into two non-empty substrings `(s1_left, s1_right)` and `(s2_left, s2_right)` such that:
 1. `s1_left` is a scramble of `s2_left` AND `s1_right` is a scramble of `s2_right` (no swap occurred).
 OR
 2. `s1_left` is a scramble of `s2_right` AND `s1_right` is a scramble of `s2_left` (swap occurred).
 To optimize and prevent checking deeply, before recursing, we verify if `s1` and `s2` have the 
 same character counts. If they don't, they cannot be scrambles. We also memoize results.

 Time Complexity: O(N^4) with memoization in the worst case (where N is the string length). 
 There are O(N^3) states (start1, start2, length), and each state takes O(N) to compute.
 Space Complexity: O(N^3) to store the memoization cache.
*/

class Solution {
    func isScramble(_ s1: String, _ s2: String) -> Bool {
        var memo = [String: Bool]()
        return dfs(s1, s2, &memo)
    }
    
    private func dfs(_ s1: String, _ s2: String, _ memo: inout [String: Bool]) -> Bool {
        // Base cases
        if s1 == s2 { return true }
        if s1.count != s2.count { return false }
        
        let key = s1 + "-" + s2
        if let cached = memo[key] {
            return cached
        }
        
        // Pruning: Check if they have the same characters
        if !hasSameCharacters(s1, s2) {
            memo[key] = false
            return false
        }
        
        let n = s1.count
        let chars1 = Array(s1)
        let chars2 = Array(s2)
        
        // Try splitting at every possible length from 1 to n - 1
        for i in 1..<n {
            // Case 1: No swap
            let s1Left1 = String(chars1[0..<i])
            let s1Right1 = String(chars1[i..<n])
            let s2Left1 = String(chars2[0..<i])
            let s2Right1 = String(chars2[i..<n])
            
            if dfs(s1Left1, s2Left1, &memo) && dfs(s1Right1, s2Right1, &memo) {
                memo[key] = true
                return true
            }
            
            // Case 2: Swap
            let s1Left2 = String(chars1[0..<i])
            let s1Right2 = String(chars1[i..<n])
            let s2Left2 = String(chars2[(n-i)..<n])
            let s2Right2 = String(chars2[0..<(n-i)])
            
            if dfs(s1Left2, s2Left2, &memo) && dfs(s1Right2, s2Right2, &memo) {
                memo[key] = true
                return true
            }
        }
        
        memo[key] = false
        return false
    }
    
    private func hasSameCharacters(_ s1: String, _ s2: String) -> Bool {
        var counts = [Character: Int]()
        for char in s1 { counts[char, default: 0] += 1 }
        for char in s2 {
            if let count = counts[char] {
                if count == 1 { counts.removeValue(forKey: char) }
                else { counts[char] = count - 1 }
            } else {
                return false
            }
        }
        return counts.isEmpty
    }
}
