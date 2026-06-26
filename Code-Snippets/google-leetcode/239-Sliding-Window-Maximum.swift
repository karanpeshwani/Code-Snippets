// 239. Sliding Window Maximum
// Link: https://leetcode.com/problems/sliding-window-maximum/
//
// Time Complexity: O(N), where N is the number of elements in the array.
// Explanation: Each element is added and removed from the deque at most once, leading to a linear time traversal.
// Space Complexity: O(k), where k is the window size.
// Explanation: The deque stores at most k elements at any point in time.

import Collections

class Solution {
    func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
        if nums.isEmpty || k == 0 { return [] }
        
        var result = [Int]()
        // Deque stores the INDICES of elements, not the values themselves
        var deque = Deque<Int>()
        
        for i in 0..<nums.count {
            // Remove indices that are out of the current sliding window
            if let first = deque.first, first < i - k + 1 {
                deque.removeFirst()
            }
            
            // Remove indices whose values are smaller than the current element
            // because they can never be the maximum in any future window
            while let last = deque.last, nums[last] < nums[i] {
                deque.removeLast()
            }
            
            // Add current element's index
            deque.append(i)
            
            // The first element in the deque is the index of the largest element in the window
            if i >= k - 1 {
                result.append(nums[deque.first!])
            }
        }
        
        return result
    }
}
