// 1095. Find in Mountain Array
// https://leetcode.com/problems/find-in-mountain-array

/*
 Intuition:
 The problem asks us to find the minimum index of a target value in a "Mountain Array"
 (an array that strictly increases to a peak element and then strictly decreases).
 Since the array is monotonic in two parts, we can use Binary Search.
 
 1. Find the peak of the mountain using Binary Search. We compare `mid` with `mid + 1`
    to determine if we are on the ascending or descending slope.
 2. Perform Binary Search on the ascending left part (from index 0 to peak).
    If we find the target, return its index since we want the minimum index.
 3. If the target is not found in the left part, perform Binary Search on the descending
    right part (from peak + 1 to length - 1).

 Time Complexity: O(log N)
 - Finding the peak takes O(log N) API calls.
 - Searching the left part takes O(log N) API calls.
 - Searching the right part takes O(log N) API calls.
 - Overall time complexity is bounded by O(log N).

 Space Complexity: O(1)
 - We only use a few variables for pointers and values.
 - No extra space is required.
 - Overall space complexity is O(1).
 */

/**
 * // This is MountainArray's API interface.
 * // You should not implement it, or speculate about its implementation
 * class MountainArray {
 *     public func get(_ index: Int) -> Int {}
 *     public func length() -> Int {}
 * }
 */

class Solution {
    func findInMountainArray(_ target: Int, _ mountainArr: MountainArray) -> Int {
        let length = mountainArr.length()
        
        // 1. Find the index of the peak element
        var left = 0
        var right = length - 1
        var peak = 0
        
        while left < right {
            let mid = left + (right - left) / 2
            let midValue = mountainArr.get(mid)
            let nextValue = mountainArr.get(mid + 1)
            
            if midValue < nextValue {
                // We are on the ascending slope
                left = mid + 1
            } else {
                // We are on the descending slope or at the peak
                right = mid
            }
        }
        peak = left
        
        // 2. Binary search on the ascending left part
        left = 0
        right = peak
        while left <= right {
            let mid = left + (right - left) / 2
            let midValue = mountainArr.get(mid)
            
            if midValue == target {
                return mid
            } else if midValue < target {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        // 3. Binary search on the descending right part
        left = peak + 1
        right = length - 1
        while left <= right {
            let mid = left + (right - left) / 2
            let midValue = mountainArr.get(mid)
            
            if midValue == target {
                return mid
            } else if midValue > target {
                // Since it's descending, if midValue is greater, target is to the right
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        return -1
    }
}
