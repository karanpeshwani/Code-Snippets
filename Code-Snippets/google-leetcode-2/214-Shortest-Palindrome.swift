// 214. Shortest Palindrome
// https://leetcode.com/problems/shortest-palindrome
//
// Intuition/Explanation:
// We need to find the longest palindromic prefix of the string `s`.
// Once we find it, we can reverse the remaining suffix and prepend it to `s` to make it a palindrome.
// We can use the KMP (Knuth-Morris-Pratt) algorithm's partial match table (LPS - Longest Prefix Suffix) 
// to do this in O(N) time.
// We create a new string `new_s = s + "#" + reversed(s)`. The "#" acts as a separator.
// The last value in the LPS array for `new_s` will give us the length of the longest palindromic prefix of `s`.
// For example, if s = "aacecaaa", reversed = "aaacecaa", new_s = "aacecaaa#aaacecaa".
// The longest prefix of `new_s` that is also a suffix will correspond to the longest palindromic prefix in `s`.
//
// Time Complexity: O(N), where N is the length of the string `s`. The LPS array construction is linear.
// Space Complexity: O(N) for creating the concatenated string and the LPS array.

class Solution {
    func shortestPalindrome(_ s: String) -> String {
        guard !s.isEmpty else { return "" }
        
        let reversedS = String(s.reversed())
        let newS = s + "#" + reversedS
        let newChars = Array(newS)
        let n = newChars.count
        
        var lps = Array(repeating: 0, count: n)
        
        // Build LPS array
        var j = 0
        for i in 1..<n {
            while j > 0 && newChars[i] != newChars[j] {
                j = lps[j - 1]
            }
            if newChars[i] == newChars[j] {
                j += 1
            }
            lps[i] = j
        }
        
        // The length of the longest palindromic prefix is the last value in LPS
        let longestPalindromePrefixLength = lps[n - 1]
        
        // If the whole string is a palindrome
        if longestPalindromePrefixLength == s.count {
            return s
        }
        
        // Get the suffix that needs to be reversed and prepended
        let sChars = Array(s)
        let suffix = String(sChars[longestPalindromePrefixLength..<s.count])
        
        return String(suffix.reversed()) + s
    }
}
