//Again
// 862. Shortest Subarray with Sum at Least K
// https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k
//
// Time Complexity: O(N), where N is the number of elements in the array. We compute the prefix sums in O(N) time and then each index is pushed and popped from the monotonic deque at most once.
// Space Complexity: O(N), for storing the prefix sums and the monotonic deque.

import Collections

class Solution {
    func shortestSubarray(_ nums: [Int], _ k: Int) -> Int {
        let n = nums.count
        // prefixSum[i] stores the sum of elements from nums[0] to nums[i-1]
        var prefixSum = [Int](repeating: 0, count: n + 1)
        for i in 0..<n {
            prefixSum[i + 1] = prefixSum[i] + nums[i]
        }
        
        var minLength = Int.max
        // Deque to store indices of prefixSum in monotonically increasing order
        var deque = Deque<Int>()
        
        for i in 0...n {
            // If the difference between current prefix sum and the smallest prefix sum in deque >= k
            // We found a valid subarray. Update minLength and remove the first element 
            // since we want the shortest subarray and subsequent indices (j > i) 
            // will only result in longer subarrays for this deque.first
            while let first = deque.first, prefixSum[i] - prefixSum[first] >= k {
                minLength = min(minLength, i - first)
                deque.removeFirst()
            }
            
            // Maintain monotonic increasing order in the deque.
            // If the current prefix sum is less than or equal to the prefix sum at the back of deque,
            // we remove elements from the back. This is because any future index j (j > i) 
            // that satisfies prefixSum[j] - prefixSum[back] >= k will also satisfy 
            // prefixSum[j] - prefixSum[i] >= k, and the subarray ending at j starting after i 
            // will be shorter.
            while let last = deque.last, prefixSum[i] <= prefixSum[last] {
                deque.removeLast()
            }
            
            // Add current index to the deque
            deque.append(i)
        }
        
        return minLength == Int.max ? -1 : minLength
    }
}
