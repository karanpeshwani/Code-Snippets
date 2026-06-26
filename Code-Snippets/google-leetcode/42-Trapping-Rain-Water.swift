// 42. Trapping Rain Water
// Link: https://leetcode.com/problems/trapping-rain-water/
//
// Time Complexity: O(N), where N is the number of elements in the height array.
// Explanation: We iterate through the array once using two pointers, taking constant time at each step.
// Space Complexity: O(1)
// Explanation: We only use a few variables for pointers and max heights, requiring constant extra space.

class Solution {
    func trap(_ height: [Int]) -> Int {
        if height.isEmpty { return 0 }
        
        // Two pointers moving from the edges to the center
        var left = 0
        var right = height.count - 1
        
        // Keep track of the maximum heights seen from the left and right
        var leftMax = height[left]
        var rightMax = height[right]
        
        var totalWater = 0
        
        while left < right {
            if leftMax < rightMax {
                // If leftMax is smaller, we know water trapped at 'left' is bounded by leftMax
                left += 1
                leftMax = max(leftMax, height[left])
                totalWater += leftMax - height[left]
            } else {
                // If rightMax is smaller or equal, water trapped at 'right' is bounded by rightMax
                right -= 1
                rightMax = max(rightMax, height[right])
                totalWater += rightMax - height[right]
            }
        }
        
        return totalWater
    }
}
