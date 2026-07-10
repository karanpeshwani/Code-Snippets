// 727. Minimum Window Subsequence
// https://leetcode.com/problems/minimum-window-subsequence/

/*
 Intuition:
 We need to find the minimum contiguous substring of `s1` that contains `s2` as a subsequence.
 We can use a two-pointer approach simulating a bidirectional search.
 1. Forward search: find the first window that contains `s2`. We move a pointer in `s1` to match `s2`.
 2. Backward search: once we find a match, the end of the window is determined. However, the start might not be optimal.
    We search backwards from the end of the matched window to find the latest possible start index that still contains `s2`.
 3. After recording the optimal window, we resume the forward search from `start + 1` to find other potential windows.

 Time Complexity: O(M * N)
 - M is the length of string `s1` and N is the length of string `s2`.
 - For each match of `s2`, we do a backward search of length at most M. Thus, the worst-case time is O(M * N).

 Space Complexity: O(M + N) or O(1)
 - Converting strings to arrays for efficient indexing takes O(M + N) space.
 - Excluding the string array conversions, the space complexity is O(1).
 */

class Solution {
    func minWindow(_ s1: String, _ s2: String) -> String {
        let s1Chars = Array(s1)
        let s2Chars = Array(s2)
        let m = s1Chars.count
        let n = s2Chars.count
        
        var minLen = Int.max
        var minStart = -1
        
        var i = 0
        while i < m {
            // Forward search to find a window
            var j = 0
            while i < m {
                if s1Chars[i] == s2Chars[j] {
                    j += 1
                    if j == n {
                        break
                    }
                }
                i += 1
            }
            
            // If we didn't find a full match, we are done
            if j < n {
                break
            }
            
            // Backward search to optimize the start of the window
            let end = i
            j = n - 1
            while j >= 0 {
                if s1Chars[i] == s2Chars[j] {
                    j -= 1
                }
                if j >= 0 {
                    i -= 1
                }
            }
            
            let start = i
            let len = end - start + 1
            if len < minLen {
                minLen = len
                minStart = start
            }
            
            // Resume search from the next character of the optimized start
            i = start + 1
        }
        
        return minStart == -1 ? "" : String(s1Chars[minStart..<(minStart + minLen)])
    }
}
