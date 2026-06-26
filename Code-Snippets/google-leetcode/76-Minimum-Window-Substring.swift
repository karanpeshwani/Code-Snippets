// 76. Minimum Window Substring
// Link: https://leetcode.com/problems/minimum-window-substring/
//
// Time Complexity: O(M + N), where M and N are the lengths of strings s and t.
// Explanation: Both the right and left pointers iterate through the string 's' at most once. We also iterate 't' once.
// Space Complexity: O(M + N) to store UTF-8 representations for fast access, and O(1) auxiliary space.
// Explanation: The character frequency arrays require constant space (128 ASCII characters). The string array conversion takes O(M + N).

class Solution {
    func minWindow(_ s: String, _ t: String) -> String {
        if s.isEmpty || t.isEmpty { return "" }
        
        // Use utf8 for O(1) indexed access and better performance than String.Index
        let sChars = Array(s.utf8)
        let tChars = Array(t.utf8)
        
        var targetCounts = [Int](repeating: 0, count: 128)
        var requiredChars = 0
        
        // Count occurrences of characters in string t
        for char in tChars {
            let index = Int(char)
            if targetCounts[index] == 0 {
                requiredChars += 1
            }
            targetCounts[index] += 1
        }
        
        var windowCounts = [Int](repeating: 0, count: 128)
        var formedChars = 0
        
        // Sliding window pointers
        var left = 0
        var right = 0
        
        // Best window markers
        var minLength = Int.max
        var minLeft = 0
        var minRight = 0
        
        while right < sChars.count {
            let rChar = Int(sChars[right])
            windowCounts[rChar] += 1
            
            // Check if current character satisfies the requirement for 't'
            if targetCounts[rChar] > 0 && windowCounts[rChar] == targetCounts[rChar] {
                formedChars += 1
            }
            
            // Contract the window from the left if all requirements are satisfied
            while left <= right && formedChars == requiredChars {
                let currentLength = right - left + 1
                
                // Keep track of the smallest valid window
                if currentLength < minLength {
                    minLength = currentLength
                    minLeft = left
                    minRight = right
                }
                
                let lChar = Int(sChars[left])
                windowCounts[lChar] -= 1
                
                // If removing the left character breaks the required frequency, update formedChars
                if targetCounts[lChar] > 0 && windowCounts[lChar] < targetCounts[lChar] {
                    formedChars -= 1
                }
                
                left += 1
            }
            
            right += 1
        }
        
        if minLength == Int.max { return "" }
        
        // Construct the result substring using String indices to avoid creating intermediate Strings
        let startIndex = s.index(s.startIndex, offsetBy: minLeft)
        let endIndex = s.index(s.startIndex, offsetBy: minRight)
        
        return String(s[startIndex...endIndex])
    }
}
