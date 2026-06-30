//Again
// 719-Find-K-th-Smallest-Pair-Distance.swift
// 719. Find K-th Smallest Pair Distance
// https://leetcode.com/problems/find-k-th-smallest-pair-distance/
//
// Time Complexity: O(N log N + N log W) where N is the length of nums and W is the maximum possible distance (max_val - min_val).
// We sort the array in O(N log N). The binary search takes O(log(W)) and counting pairs takes O(N).
// Space Complexity: O(1) or O(N) depending on the sorting algorithm implementation in Swift.

class Solution {
    func smallestDistancePair(_ nums: [Int], _ k: Int) -> Int {
        var nums = nums
        nums.sort()
        
        var low = 0
        var high = nums.last! - nums.first!
        
        func countPairsWithSumLessOrEqual(_ target: Int) -> Int {
            var count = 0
            var left = 0
            for right in 0..<nums.count {
                while nums[right] - nums[left] > target {
                    left += 1
                }
                count += right - left
            }
            return count
        }
        
        while low < high {
            let mid = low + (high - low) / 2
            if countPairsWithSumLessOrEqual(mid) >= k {
                high = mid
            } else {
                low = mid + 1
            }
        }
        
        return low
    }
}
