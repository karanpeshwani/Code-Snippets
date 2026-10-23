// 980. Unique Paths III
// https://leetcode.com/problems/unique-paths-iii

/*
 Intuition:
 We need to find paths from the start square to the end square that walk over every non-obstacle square exactly once.
 Since the grid is very small (m * n <= 20), we can use backtracking (DFS) to explore all possible paths.
 First, we iterate through the grid to find the starting position and count the total number of non-obstacle squares
 (empty squares + start square + end square). This count represents the required length of our path.
 During DFS, we mark the current cell as visited (e.g., by changing its value to an obstacle `-1`),
 explore all 4 valid neighbors, and then backtrack by restoring the cell's original value.
 If we reach the end square and have visited the required number of squares, we increment our path count.

 Time Complexity: O(3^N)
 - N is the total number of non-obstacle cells.
 - At each step, we have at most 3 directions to explore (since we can't go back to the previous cell).
 - The time complexity is bounded by O(3^N), which is well within limits for N <= 20.

 Space Complexity: O(N)
 - The space complexity is determined by the maximum depth of the recursion stack, which is exactly N.
 - We modify the grid in place to track visited cells, requiring no extra space for a visited matrix.
 - Overall space complexity is O(N).
 */

class Solution {
    func uniquePathsIII(_ grid: [[Int]]) -> Int {
        var grid = grid
        let m = grid.count
        let n = grid[0].count
        
        var startRow = 0
        var startCol = 0
        var emptyCount = 1 // Start counting at 1 to include the start square
        
        // Find the start square and count the number of non-obstacle squares
        for r in 0..<m {
            for c in 0..<n {
                if grid[r][c] == 1 {
                    startRow = r
                    startCol = c
                } else if grid[r][c] == 0 {
                    emptyCount += 1
                }
            }
        }
        
        var pathCount = 0
        
        func dfs(_ r: Int, _ c: Int, _ remaining: Int) {
            // Check bounds and obstacles
            if r < 0 || r >= m || c < 0 || c >= n || grid[r][c] == -1 {
                return
            }
            
            // If we reach the end square
            if grid[r][c] == 2 {
                if remaining == 0 {
                    pathCount += 1
                }
                return
            }
            
            // Mark as visited by temporarily setting to -1
            let temp = grid[r][c]
            grid[r][c] = -1
            
            // Explore 4 directions
            dfs(r + 1, c, remaining - 1)
            dfs(r - 1, c, remaining - 1)
            dfs(r, c + 1, remaining - 1)
            dfs(r, c - 1, remaining - 1)
            
            // Backtrack
            grid[r][c] = temp
        }
        
        dfs(startRow, startCol, emptyCount)
        
        return pathCount
    }
}
