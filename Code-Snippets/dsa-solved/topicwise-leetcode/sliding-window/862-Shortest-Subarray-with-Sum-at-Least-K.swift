// 862. Shortest Subarray with Sum at Least K
// https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/

/*
 Intuition:
 We need to find the shortest subarray with a sum of at least `k`.
 Since the array can contain negative numbers, a simple sliding window won't work because the sum doesn't monotonically increase.
 We can use a prefix sum array and a monotonic deque to solve this efficiently.
 The deque will store indices of the prefix sum array in increasing order of their prefix sum values.
 For each index `i`, we check if `prefixSum[i] - prefixSum[deque.first]` >= `k`.
 If it is, we have found a valid subarray. We update the minimum length and remove the front element
 because we want the shortest subarray, and any future `j > i` with this same starting point will only result in a longer subarray.
 Also, to maintain the monotonicity of the deque, we remove elements from the back if their prefix sum is greater than
 or equal to `prefixSum[i]`. This is because `prefixSum[i]` provides a smaller value at a later index, making it
 a better candidate for future subarrays.

 Time Complexity: O(N)
 - N is the number of elements in `nums`.
 - We calculate prefix sums in O(N).
 - Each index is added to and removed from the deque at most once.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - The prefix sum array requires O(N) space.
 - The deque can store at most N + 1 elements.
 - Overall space complexity is O(N).
 */

import Collections

class Solution {
    func shortestSubarray(_ nums: [Int], _ k: Int) -> Int {
        let n = nums.count
        var prefixSums = [Int](repeating: 0, count: n + 1)
        
        // Compute prefix sums
        for i in 0..<n {
            prefixSums[i + 1] = prefixSums[i] + nums[i]
        }
        
        var minLen = Int.max
        var deque = Deque<Int>()
        
        for i in 0...n {
            // Check if we found a valid subarray
            while let first = deque.first, prefixSums[i] - prefixSums[first] >= k {
                minLen = min(minLen, i - first)
                deque.popFirst()
            }
            
            // Maintain monotonic property of the deque
            while let last = deque.last, prefixSums[i] <= prefixSums[last] {
                deque.popLast()
            }
            
            deque.append(i)
        }
        
        return minLen == Int.max ? -1 : minLen
    }
}
