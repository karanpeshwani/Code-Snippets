// 44. Wildcard Matching
// https://leetcode.com/problems/wildcard-matching
//
// Intuition/Explanation:
// We can use a greedy two-pointer approach for optimal time complexity.
// We maintain pointers `sIdx` for string `s` and `pIdx` for pattern `p`.
// - If characters match or `p` has '?', we advance both pointers.
// - If `p` has '*', we record the current `sIdx` as `match` and `pIdx` as `starIdx`, then advance `pIdx` 
//   (greedily assuming '*' matches zero characters first).
// - If there's a mismatch but we've seen a '*', we go back to the last '*', advance `match` by 1 
//   (trying to match one more character of `s` with '*'), and reset `sIdx` and `pIdx`.
// - If there's a mismatch and no '*' was seen, return false.
// Finally, we check if any remaining characters in `p` are all '*'.
//
// Time Complexity: O(S * P) in the worst case (e.g., s="aaaaab", p="*a*a*a*a*a*c"), 
// but typically O(S + P) average time complexity.
// Space Complexity: O(1), since we only use integer variables for pointers.

class Solution {
    func isMatch(_ s: String, _ p: String) -> Bool {
        let sChars = Array(s)
        let pChars = Array(p)
        let sLen = sChars.count
        let pLen = pChars.count
        
        var sIdx = 0
        var pIdx = 0
        var starIdx = -1
        var match = -1
        
        while sIdx < sLen {
            // Match single character or '?'
            if pIdx < pLen && (pChars[pIdx] == "?" || pChars[pIdx] == sChars[sIdx]) {
                sIdx += 1
                pIdx += 1
            }
            // '*' found, record positions and try matching zero characters first
            else if pIdx < pLen && pChars[pIdx] == "*" {
                starIdx = pIdx
                match = sIdx
                pIdx += 1
            }
            // Mismatch, but we have a previous '*', so backtrack and match one more character of 's'
            else if starIdx != -1 {
                pIdx = starIdx + 1
                match += 1
                sIdx = match
            }
            // Mismatch and no previous '*'
            else {
                return false
            }
        }
        
        // Check if remaining characters in 'p' are all '*'
        while pIdx < pLen && pChars[pIdx] == "*" {
            pIdx += 1
        }
        
        return pIdx == pLen
    }
}
