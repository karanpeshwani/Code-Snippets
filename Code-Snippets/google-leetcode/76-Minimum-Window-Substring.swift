// 76. Minimum Window Substring
// Link: https://leetcode.com/problems/minimum-window-substring/
//
// Time Complexity: O(M + N), where M and N are the lengths of strings s and t.
// Explanation: The window iterates over 's' and 't' at most once. Dictionary lookups take O(1) average time.
// Space Complexity: O(M + N) for the Character array conversion, plus O(U) for dictionaries (where U is unique characters).

class Solution {
    func minWindow(_ s: String, _ t: String) -> String {
        if s.isEmpty || t.isEmpty { return "" }

        let sChars = Array(s)

        // Used a Map (Dictionary) here. We can also use asciiValue array like: var targetCounts = [Int](repeating: 0, count: 128)
        var targetCounts = [Character: Int]()

        // Count occurrences of characters in string t
        for char in t {
            targetCounts[char, default: 0] += 1
        }

        // The number of unique characters we need to match
        let requiredChars = targetCounts.count

        var windowCounts = [Character: Int]()
        var formedChars = 0

        var left = 0

        // Best window markers
        var minLength = Int.max
        var minLeft = 0
        var minRight = 0

        for right in 0..<sChars.count {
            let rChar = sChars[right]
            windowCounts[rChar, default: 0] += 1

            // Check if current character satisfies the requirement for 't'
            if let target = targetCounts[rChar], windowCounts[rChar] == target {
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

                let lChar = sChars[left]
                windowCounts[lChar, default: 0] -= 1

                // If removing the left character breaks the required frequency, update formedChars
                if let target = targetCounts[lChar], windowCounts[lChar, default: 0] < target {
                    formedChars -= 1
                }

                left += 1
            }
        }

        if minLength == Int.max { return "" }

        // Construct the result substring using String indices
        let startIndex = s.index(s.startIndex, offsetBy: minLeft)
        let endIndex = s.index(s.startIndex, offsetBy: minRight)

        return String(s[startIndex...endIndex])
    }
}