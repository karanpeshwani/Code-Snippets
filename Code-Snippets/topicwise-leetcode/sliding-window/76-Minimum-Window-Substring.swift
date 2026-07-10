// 76. Minimum Window Substring
// https://leetcode.com/problems/minimum-window-substring/

/*
 Intuition:
 The problem asks for the minimum window in `s` which contains all the characters in `t`.
 We can use a sliding window approach with two pointers, `left` and `right`.
 We expand the window by moving `right` to include characters until we have all required characters from `t`.
 Once the window contains all required characters, we try to shrink it from the `left` to find the minimum possible valid window.
 We keep track of the required character counts using an array or dictionary, and a `required` counter to know when all characters are matched.

 Time Complexity: O(M + N)
 - M is the length of string `s` and N is the length of string `t`.
 - Both `left` and `right` pointers traverse the string `s` at most once.
 - Building the frequency map for `t` takes O(N) time.
 - Total time complexity is O(M + N).

 Space Complexity: O(1) or O(K)
 - We use an array of size 128 to store character frequencies (since it's ASCII).
 - K is the size of the character set, which is constant (128).
 - Therefore, the space complexity is O(1).
 */

class Solution {
    func minWindow(_ s: String, _ t: String) -> String {
        let sChars = Array(s)
        var tCount = [Int](repeating: 0, count: 128)
        
        // Count characters in t
        for char in t {
            tCount[Int(char.asciiValue!)] += 1
        }
        
        var required = t.count
        var left = 0
        var right = 0
        var minLen = Int.max
        var minStart = 0
        
        while right < sChars.count {
            let rightCharIdx = Int(sChars[right].asciiValue!)
            
            // Expand the window
            if tCount[rightCharIdx] > 0 {
                required -= 1
            }
            tCount[rightCharIdx] -= 1
            right += 1
            
            // Shrink the window
            while required == 0 {
                if right - left < minLen {
                    minLen = right - left
                    minStart = left
                }
                
                let leftCharIdx = Int(sChars[left].asciiValue!)
                tCount[leftCharIdx] += 1
                if tCount[leftCharIdx] > 0 {
                    required += 1
                }
                left += 1
            }
        }
        
        return minLen == Int.max ? "" : String(sChars[minStart..<(minStart + minLen)])
    }
}
