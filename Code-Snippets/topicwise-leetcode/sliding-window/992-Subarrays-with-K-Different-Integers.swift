// 992. Subarrays with K Different Integers
// https://leetcode.com/problems/subarrays-with-k-different-integers/

/*
 Intuition:
 Counting exactly K different integers in a sliding window is tricky.
 However, calculating the number of subarrays with AT MOST K different integers is straightforward using a standard sliding window.
 If we define a function `atMost(k)` that returns the number of subarrays with at most `k` distinct integers,
 then the number of subarrays with EXACTLY `k` distinct integers is `atMost(k) - atMost(k - 1)`.
 For `atMost(k)`, we expand the window `[left, right]` and keep a count of element frequencies.
 If the number of distinct elements exceeds `k`, we shrink the window from the left until the distinct count is valid.
 For any valid window `[left, right]`, there are `right - left + 1` valid subarrays ending at `right`.

 Time Complexity: O(N)
 - N is the number of elements in `nums`.
 - For both `atMost(k)` and `atMost(k - 1)`, each element is added and removed from the sliding window at most once.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - We use an array to keep track of the frequency of elements in the current window.
 - In the worst case, the frequency map requires O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    func subarraysWithKDistinct(_ nums: [Int], _ k: Int) -> Int {
        return atMost(nums, k) - atMost(nums, k - 1)
    }
    
    private func atMost(_ nums: [Int], _ k: Int) -> Int {
        if k == 0 { return 0 }
        
        // Element values in nums are strictly from 1 to nums.count
        var counts = [Int](repeating: 0, count: nums.count + 1)
        var left = 0
        var totalSubarrays = 0
        var distinctCount = 0
        
        for right in 0..<nums.count {
            let numRight = nums[right]
            
            // If it's a new distinct element, increase distinct count
            if counts[numRight] == 0 {
                distinctCount += 1
            }
            counts[numRight] += 1
            
            // Shrink the window until distinct elements are within k
            while distinctCount > k {
                let numLeft = nums[left]
                counts[numLeft] -= 1
                if counts[numLeft] == 0 {
                    distinctCount -= 1
                }
                left += 1
            }
            
            // Add number of valid subarrays ending at 'right'
            totalSubarrays += right - left + 1
        }
        
        return totalSubarrays
    }
}
