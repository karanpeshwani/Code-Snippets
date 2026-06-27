// 52. N-Queens II
// https://leetcode.com/problems/n-queens-ii
//
// Time Complexity: O(N!)
// Space Complexity: O(N)
//
// Explanation:
// We use backtracking to place queens row by row.
// To efficiently check if a queen can be placed at (row, col), we maintain three sets (or bitmasks) to track:
// 1. Columns that already have a queen.
// 2. Main diagonals (row - col) that already have a queen.
// 3. Anti-diagonals (row + col) that already have a queen.
// We recursively try placing a queen in each column of the current row. If valid, we update the sets and move to the next row.
// If we reach the end of the rows (row == N), we found a valid placement, so we increment our count.
// Using bitwise operations for tracking availability makes it extremely fast.
// Time complexity is bounded by O(N!), the maximum number of states. Space is O(N) for recursion depth.

class Solution {
    func totalNQueens(_ n: Int) -> Int {
        var count = 0
        
        func backtrack(row: Int, cols: Int, diags: Int, antiDiags: Int) {
            // Base case: all queens are placed successfully
            if row == n {
                count += 1
                return
            }
            
            // Available positions in the current row
            // (cols | diags | antiDiags) represents all attacked positions
            // We invert it and mask with (1 << n) - 1 to keep only the valid n bits
            var availablePositions = ((1 << n) - 1) & ~(cols | diags | antiDiags)
            
            while availablePositions > 0 {
                // Get the lowest available bit (position)
                let position = availablePositions & -availablePositions
                
                // Remove the position from available positions
                availablePositions &= (availablePositions - 1)
                
                // Recursively place queens in the next row
                // diags shift right by 1, antiDiags shift left by 1 for the next row
                backtrack(
                    row: row + 1,
                    cols: cols | position,
                    diags: (diags | position) >> 1,
                    antiDiags: (antiDiags | position) << 1
                )
            }
        }
        
        backtrack(row: 0, cols: 0, diags: 0, antiDiags: 0)
        return count
    }
}
