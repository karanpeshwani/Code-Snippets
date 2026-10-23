// 546. Remove Boxes
// https://leetcode.com/problems/remove-boxes

/*
 Intuition:
 The problem asks for the maximum points by removing boxes of the same color.
 This can be modeled with dynamic programming. The state can be defined as `dp(l, r, k)`,
 which represents the maximum points we can get from the subarray `boxes[l...r]`,
 given that there are `k` boxes of the same color as `boxes[l]` attached to the left of `boxes[l]`.
 
 Transitions:
 1. We can remove `boxes[l]` along with the `k` boxes of the same color attached to its left.
    The points gained will be `(k + 1) * (k + 1)`, and the remaining problem is `dp(l + 1, r, 0)`.
 2. We can try to attach `boxes[l]` to some other box `boxes[i]` (where l < i <= r) of the same color.
    By doing so, we need to remove the boxes between `l` and `i` first, which gives `dp(l + 1, i - 1, 0)`.
    Then, the remaining problem becomes `dp(i, r, k + 1)`.
 We take the maximum of these choices. To optimize, we can collapse contiguous identical boxes.

 Time Complexity: O(N^4)
 - There are N^3 states for `(l, r, k)`.
 - For each state, we iterate up to N times to find matching colors.
 - Overall time complexity is O(N^4).

 Space Complexity: O(N^3)
 - We use a memoization table of size N x N x N to store the results of subproblems.
 - Overall space complexity is O(N^3).
 */

class Solution {
    func removeBoxes(_ boxes: [Int]) -> Int {
        let n = boxes.count
        if n == 0 { return 0 }
        
        // Memoization table initialized with 0
        var memo = Array(repeating: Array(repeating: Array(repeating: 0, count: n), count: n), count: n)
        
        func dp(_ l: Int, _ r: Int, _ k: Int) -> Int {
            if l > r { return 0 }
            
            if memo[l][r][k] > 0 {
                return memo[l][r][k]
            }
            
            var currentL = l
            var currentK = k
            
            // Optimization: group identical colors
            while currentL + 1 <= r && boxes[currentL] == boxes[currentL + 1] {
                currentL += 1
                currentK += 1
            }
            
            // Option 1: Remove boxes[currentL] and its left attachments
            var maxPoints = (currentK + 1) * (currentK + 1) + dp(currentL + 1, r, 0)
            
            // Option 2: Try to attach with another box of the same color
            for i in (currentL + 1)...r {
                if boxes[i] == boxes[currentL] {
                    maxPoints = max(maxPoints, dp(currentL + 1, i - 1, 0) + dp(i, r, currentK + 1))
                }
            }
            
            memo[l][r][k] = maxPoints
            return maxPoints
        }
        
        return dp(0, n - 1, 0)
    }
}
