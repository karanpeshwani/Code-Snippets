// 84. Largest Rectangle in Histogram
// https://leetcode.com/problems/largest-rectangle-in-histogram
//
// Intuition/Explanation:
// We can use a monotonic increasing stack to efficiently find the largest rectangle.
// The stack will store the indices of the histogram bars such that their heights are strictly increasing.
// We iterate through the array. If we see a bar smaller than the bar at the top of the stack,
// it means the bar at the top of the stack cannot be extended further to the right.
// So, we pop the top index, calculate the area with it as the smallest height, and update our max area.
// The width of this rectangle is `current index - new top of stack - 1`. 
// If the stack is empty after popping, the width is just the `current index`.
// We append a dummy 0-height bar at the end to ensure all remaining bars in the stack are processed.
//
// Time Complexity: O(N), where N is the number of bars. Every bar is pushed and popped from the stack at most once.
// Space Complexity: O(N) to store the indices in the stack in the worst case (e.g., strictly increasing array).

class Solution {
    func largestRectangleArea(_ heights: [Int]) -> Int {
        // Append a 0 to force processing of any remaining bars in the stack at the end
        let heights = heights + [0] 
        var stack = [Int]() // Stores indices
        var maxArea = 0
        
        for i in 0..<heights.count {
            // While current bar is shorter than the bar at stack top, pop and calculate area
            while let topIndex = stack.last, heights[i] < heights[topIndex] {
                stack.removeLast()
                
                let height = heights[topIndex]
                // If stack is empty, width is `i` (meaning it extends all the way to the left)
                // Otherwise, width is between the current index `i` and the new top of the stack
                let width = stack.isEmpty ? i : (i - stack.last! - 1)
                
                maxArea = max(maxArea, height * width)
            }
            stack.append(i)
        }
        
        return maxArea
    }
}
