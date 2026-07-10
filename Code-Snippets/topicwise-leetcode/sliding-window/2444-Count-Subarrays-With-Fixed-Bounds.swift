// 2444. Count Subarrays With Fixed Bounds
// https://leetcode.com/problems/count-subarrays-with-fixed-bounds/

/*
 Intuition:
 We need to count the number of subarrays where the minimum element is exactly `minK` and the maximum is exactly `maxK`.
 Any element strictly less than `minK` or strictly greater than `maxK` is invalid and cannot be part of the subarray.
 Thus, invalid elements divide the array into valid segments.
 For a valid segment, we can maintain the most recent positions (indices) of `minK` and `maxK`.
 As we iterate through the array, if the current element is valid, the number of valid subarrays ending at the current index `i`
 is determined by the minimum of the most recent index of `minK` and `maxK`. Specifically, any subarray starting between
 the most recent invalid element index and `min(lastMinKIndex, lastMaxKIndex)` is valid.
 Therefore, we add `max(0, min(lastMinKIndex, lastMaxKIndex) - lastInvalidIndex)` to our total count.

 Time Complexity: O(N)
 - N is the number of elements in the array.
 - We iterate through the array exactly once, performing constant time operations at each step.
 - Overall time complexity is O(N).

 Space Complexity: O(1)
 - We only use a few variables to keep track of the most recent indices (`lastMinKIndex`, `lastMaxKIndex`, `lastInvalidIndex`).
 - Overall space complexity is O(1).
 */

class Solution {
    func countSubarrays(_ nums: [Int], _ minK: Int, _ maxK: Int) -> Int {
        var totalCount = 0
        var lastMinKIndex = -1
        var lastMaxKIndex = -1
        var lastInvalidIndex = -1
        
        for i in 0..<nums.count {
            let num = nums[i]
            
            if num < minK || num > maxK {
                lastInvalidIndex = i
            }
            
            if num == minK {
                lastMinKIndex = i
            }
            
            if num == maxK {
                lastMaxKIndex = i
            }
            
            let validStartRange = min(lastMinKIndex, lastMaxKIndex)
            if validStartRange > lastInvalidIndex {
                totalCount += validStartRange - lastInvalidIndex
            }
        }
        
        return totalCount
    }
}
