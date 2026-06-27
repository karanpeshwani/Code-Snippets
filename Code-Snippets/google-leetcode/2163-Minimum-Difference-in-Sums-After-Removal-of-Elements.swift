// 2163-Minimum-Difference-in-Sums-After-Removal-of-Elements.swift
// 2163. Minimum Difference in Sums After Removal of Elements
// https://leetcode.com/problems/minimum-difference-in-sums-after-removal-of-elements/
//
// Time Complexity: O(N log N) using heaps (priority queues) where N is the length of the array after removal.
// We process elements from left and right maintaining a heap of size N.
// Space Complexity: O(N) to store prefixes, suffixes, and the elements in the heap.

import Collections

class Solution {
    func minimumDifference(_ nums: [Int]) -> Int {
        let n = nums.count / 3
        var minHeap = Heap<Int>()
        var maxHeap = Heap<Int>() 
        
        // Compute minimal sums for the first part
        var prefixSums = Array(repeating: 0, count: nums.count)
        var sum = 0
        for i in 0..<(2 * n) {
            maxHeap.insert(nums[i]) // we want to remove the largest elements
            sum += nums[i]
            if maxHeap.count > n {
                sum -= maxHeap.removeMax()
            }
            prefixSums[i] = sum
        }
        
        // Compute maximal sums for the second part
        var suffixSums = Array(repeating: 0, count: nums.count)
        sum = 0
        for i in stride(from: nums.count - 1, through: n, by: -1) {
            minHeap.insert(nums[i]) // we want to remove the smallest elements
            sum += nums[i]
            if minHeap.count > n {
                sum -= minHeap.removeMin()
            }
            suffixSums[i] = sum
        }
        
        // Find the split point that minimizes difference
        var minDiff = Int.max
        for i in (n - 1)..<(2 * n) {
            minDiff = min(minDiff, prefixSums[i] - suffixSums[i + 1])
        }
        return minDiff
    }
}
