// 239. Sliding Window Maximum
// https://leetcode.com/problems/sliding-window-maximum/

/*
 Intuition:
 We need to find the maximum element in every window of size `k`.
 A naive approach takes O(N * K) time. We can optimize this to O(N) using a Monotonic Deque.
 The deque will store indices of elements in decreasing order of their values.
 When moving the window, we remove indices that are out of the current window from the front of the deque.
 We also remove elements from the back of the deque that are smaller than the current element,
 because they can never be the maximum in any future window.
 The element at the front of the deque is always the maximum for the current window.

 Time Complexity: O(N)
 - N is the number of elements in the array `nums`.
 - Each element is added to the deque exactly once and removed at most once.
 - Total time complexity is O(N).

 Space Complexity: O(K)
 - The deque will store at most `k` indices at any point in time.
 - Output array takes O(N - K + 1) space, but typically output space is not counted towards auxiliary space complexity.
 - Total auxiliary space complexity is O(K).
 */

import Collections

class Solution {
    func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
        var result = [Int]()
        var deque = Deque<Int>() // Stores indices of elements
        
        for i in 0..<nums.count {
            // Remove elements not within the window
            if let first = deque.first, first < i - k + 1 {
                deque.popFirst()
            }
            
            // Remove elements smaller than the current element from the back
            while let last = deque.last, nums[last] < nums[i] {
                deque.popLast()
            }
            
            // Add current element's index
            deque.append(i)
            
            // Append the maximum element to the result if the window has reached size k
            if i >= k - 1 {
                result.append(nums[deque.first!])
            }
        }
        
        return result
    }
}
