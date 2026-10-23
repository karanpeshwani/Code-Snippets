// 992. Subarrays with K Different Integers
// https://leetcode.com/problems/subarrays-with-k-different-integers

/*
 Intuition:
 Finding the number of subarrays with exactly K different integers directly using a sliding window is tricky
 because shrinking the window might not change the number of unique integers immediately.
 However, finding the number of subarrays with *at most* K different integers is a standard sliding window problem.
 Therefore, we can use the property:
 Exact(K) = AtMost(K) - AtMost(K - 1)
 We can write a helper function `atMostK` that returns the number of subarrays with at most K distinct integers.
 The number of valid subarrays ending at index `right` is `right - left + 1`.

 Time Complexity: O(N)
 - The `atMostK` function uses a sliding window where the `left` and `right` pointers both traverse the array from left to right exactly once.
 - We call the `atMostK` function twice.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - The sliding window uses a hash map or an array to keep track of the frequencies of the elements in the current window.
 - Since the elements are bounded (up to N), an array of size N + 1 can be used, taking O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    func subarraysWithKDistinct(_ nums: [Int], _ k: Int) -> Int {
        return atMostK(nums, k) - atMostK(nums, k - 1)
    }
    
    private func atMostK(_ nums: [Int], _ k: Int) -> Int {
        var count = 0
        var left = 0
        var freq = Array(repeating: 0, count: nums.count + 1)
        var distinctCount = 0
        
        for right in 0..<nums.count {
            let numRight = nums[right]
            if freq[numRight] == 0 {
                distinctCount += 1
            }
            freq[numRight] += 1
            
            while distinctCount > k {
                let numLeft = nums[left]
                freq[numLeft] -= 1
                if freq[numLeft] == 0 {
                    distinctCount -= 1
                }
                left += 1
            }
            
            // The number of subarrays ending at `right` with at most K distinct elements
            count += right - left + 1
        }
        
        return count
    }
}
