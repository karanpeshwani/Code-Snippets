// 1425. Constrained Subsequence Sum
// https://leetcode.com/problems/constrained-subsequence-sum/

/*
 Intuition:
 We need to find the maximum sum of a subsequence where the distance between any two adjacent elements is at most `k`.
 This can be modeled with dynamic programming: `dp[i]` is the maximum sum of a valid subsequence ending at index `i`.
 `dp[i] = nums[i] + max(0, max_{j=1}^{k} dp[i-j])`.
 Calculating the maximum over the last `k` elements takes O(K) per step, leading to an O(N * K) solution, which is too slow.
 We can optimize this using a sliding window and a Monotonic Deque, similar to the Sliding Window Maximum problem.
 The deque will store indices of `dp` in decreasing order of `dp` values.
 For each `i`, we first remove indices from the front of the deque that are too far (distance > `k`).
 Then, the front of the deque holds the maximum `dp` value within the valid range `[i-k, i-1]`.
 We compute `dp[i]`, and if it's strictly positive, it's worth considering for future elements. We maintain the monotonicity
 by removing elements from the back of the deque that are smaller than `dp[i]`, and then append `i`.

 Time Complexity: O(N)
 - N is the number of elements in `nums`.
 - Each index is added to and removed from the deque at most once.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - We use a `dp` array of size N (which can be optimized to store directly in `nums`).
 - The deque can store at most `k` elements.
 - Overall space complexity is O(N).
 */

import Collections

class Solution {
    func constrainedSubsetSum(_ nums: [Int], _ k: Int) -> Int {
        var dp = nums
        var deque = Deque<Int>()
        var maxSum = Int.min
        
        for i in 0..<nums.count {
            // Remove out of bounds indices
            if let first = deque.first, first < i - k {
                deque.popFirst()
            }
            
            // Add the max of the previous valid window if it's positive
            if let first = deque.first, dp[first] > 0 {
                dp[i] += dp[first]
            }
            
            maxSum = max(maxSum, dp[i])
            
            // Maintain monotonic decreasing property of the deque
            while let last = deque.last, dp[last] <= dp[i] {
                deque.popLast()
            }
            
            deque.append(i)
        }
        
        return maxSum
    }
}
