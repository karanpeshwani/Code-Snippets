// 32. Longest Valid Parentheses
// https://leetcode.com/problems/longest-valid-parentheses
//
// Intuition/Explanation:
// We can solve this optimally in O(N) time and O(1) space using a two-pass approach.
// Left to right pass: We keep track of the count of '(' (left) and ')' (right).
// - If right > left, the current substring is invalid, so we reset both to 0.
// - If left == right, we update the max length with 2 * right.
// Right to left pass: We do the same, but iterating backwards.
// - If left > right, the current substring is invalid, so we reset both to 0.
// - If left == right, we update the max length with 2 * left.
// The two passes are necessary to cover cases like "(()" (handled right-to-left) 
// and "())" (handled left-to-right).
//
// Time Complexity: O(N), where N is the length of the string. We make two passes through the string.
// Space Complexity: O(1), as we only use a few integer variables for counting.

class Solution {
    func longestValidParentheses(_ s: String) -> Int {
        var leftCount = 0
        var rightCount = 0
        var maxLength = 0
        
        // Left to right pass
        for char in s {
            if char == "(" {
                leftCount += 1
            } else {
                rightCount += 1
            }
            
            if leftCount == rightCount {
                maxLength = max(maxLength, 2 * rightCount)
            } else if rightCount > leftCount {
                leftCount = 0
                rightCount = 0
            }
        }
        
        // Reset counters for the second pass
        leftCount = 0
        rightCount = 0
        
        // Right to left pass
        for char in s.reversed() {
            if char == ")" {
                rightCount += 1
            } else {
                leftCount += 1
            }
            
            if leftCount == rightCount {
                maxLength = max(maxLength, 2 * leftCount)
            } else if leftCount > rightCount {
                leftCount = 0
                rightCount = 0
            }
        }
        
        return maxLength
    }
}
