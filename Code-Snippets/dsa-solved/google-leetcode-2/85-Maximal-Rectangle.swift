// 85. Maximal Rectangle
// https://leetcode.com/problems/maximal-rectangle

/*
 Intuition/Explanation:
 This problem can be reduced to the "Largest Rectangle in Histogram" problem.
 We process the 2D matrix row by row. For each row, we maintain a 1D array representing 
 a histogram of heights.
 If a cell is '1', its height increases by 1 compared to the previous row. 
 If it's '0', its height resets to 0 (because the column of 1s is broken).
 After updating the heights for a row, we apply the monotonic stack approach to find the 
 largest rectangle in that row's histogram and update our global maximum area.

 Time Complexity: O(R * C), where R is the number of rows and C is the number of columns. 
 We visit each cell to update heights, and computing the histogram area takes O(C) time per row.
 Space Complexity: O(C) to store the heights of the current row's histogram and the stack.
*/

class Solution {
    func maximalRectangle(_ matrix: [[Character]]) -> Int {
        guard !matrix.isEmpty else { return 0 }
        
        let cols = matrix[0].count
        var heights = Array(repeating: 0, count: cols)
        var maxArea = 0
        
        for row in matrix {
            // Update heights based on the current row
            for j in 0..<cols {
                if row[j] == "1" {
                    heights[j] += 1
                } else {
                    heights[j] = 0
                }
            }
            
            // Calculate largest rectangle for this row's histogram
            maxArea = max(maxArea, largestRectangleArea(heights))
        }
        
        return maxArea
    }
    
    // Helper function from "Largest Rectangle in Histogram"
    private func largestRectangleArea(_ heights: [Int]) -> Int {
        let heights = heights + [0]
        var stack = [Int]()
        var maxArea = 0
        
        for i in 0..<heights.count {
            while let top = stack.last, heights[i] < heights[top] {
                stack.removeLast()
                let h = heights[top]
                let w = stack.isEmpty ? i : (i - stack.last! - 1)
                maxArea = max(maxArea, h * w)
            }
            stack.append(i)
        }
        
        return maxArea
    }
}
