//Again
// 410-Split-Array-Largest-Sum.swift
// 410. Split Array Largest Sum
// https://leetcode.com/problems/split-array-largest-sum/
//
// Time Complexity: O(N * log(Sum)), where N is the length of nums and Sum is the sum of all elements.
// Binary searching the answer takes O(log(Sum)) and each check takes O(N).
// Space Complexity: O(1), as we only use a few variables.

class Solution {
    func splitArray(_ nums: [Int], _ k: Int) -> Int {
        var left = 0
        var right = 0
        for num in nums {
            left = max(left, num)
            right += num
        }
        
        // Helper function to check if we can split with max sum <= target
        func canSplit(_ target: Int) -> Bool {
            var currentSum = 0
            var chunks = 1
            for num in nums {
                if currentSum + num > target {
                    chunks += 1
                    currentSum = num
                    if chunks > k {
                        return false
                    }
                } else {
                    currentSum += num
                }
            }
            return true
        }
        
        var res = right
        while left <= right {
            let mid = left + (right - left) / 2
            if canSplit(mid) {
                res = mid
                right = mid - 1
            } else {
                left = mid + 1
            }
        }
        
        return res
    }
}
