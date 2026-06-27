// 52. N-Queens II
// https://leetcode.com/problems/n-queens-ii
//
// ---------------------------------------------------------
// COMPLEXITY ANALYSIS:
// ---------------------------------------------------------
// Time Complexity: O(N!)
// Explanation:
// In the first row, we have N choices for placing a queen.
// In the second row, we have at most N - 1 choices, in the third row N - 2 choices,
// and so on. In the absolute worst-case scenario (without any pruning), this
// yields N * (N - 1) * (N - 2) * ... * 1 = N! total operations.
// Because checking our boolean arrays takes O(1) time, the time complexity is
// strictly bounded by the number of recursive states we explore, which is O(N!).
//
// Space Complexity: O(N)
// Explanation:
// 1. Recursion Stack: We place one queen per row, so the maximum depth of our
//    recursive call stack is exactly N.
// 2. Auxiliary Arrays: We use three boolean arrays to track our state:
//    - `cols`: size N
//    - `diags`: size 2N - 1
//    - `antiDiags`: size 2N - 1
// Since all memory allocations scale linearly with N, our overall space
// complexity simplifies to O(N).
// ---------------------------------------------------------
//
// Explanation of Logic:
// We use backtracking to place queens row by row.
// Instead of bitmasking, we maintain three boolean arrays to track:
// 1. `cols`: Columns that already have a queen.
// 2. `diags`: Diagonals (row + col) that already have a queen.
// 3. `antiDiags`: Anti-diagonals (row - col + n - 1) that already have a queen.
// We recursively try placing a queen in each column of the current row.
// If it's a safe spot, we mark our arrays as `true`, proceed to the next row,
// and then backtrack by marking them as `false`.

class Solution {
    func totalNQueens(_ n: Int) -> Int {
        var count = 0

        // Boolean arrays to keep track of attacked lines
        var cols = Array(repeating: false, count: n)
        var diags = Array(repeating: false, count: 2 * n - 1)
        var antiDiags = Array(repeating: false, count: 2 * n - 1)

        func backtrack(row: Int) {
            // Base case: all queens are placed successfully
            if row == n {
                count += 1
                return
            }

            // Try placing a queen in each column of the current row
            for col in 0..<n {
                let diagIndex = row + col
                let antiDiagIndex = row - col + n - 1

                // Check if the current position is safe in O(1) time
                if !cols[col] && !diags[diagIndex] && !antiDiags[antiDiagIndex] {

                    // Mark the column and diagonals as attacked
                    cols[col] = true
                    diags[diagIndex] = true
                    antiDiags[antiDiagIndex] = true

                    // Recursively place queens in the next row
                    backtrack(row: row + 1)

                    // Backtrack: unmark the column and diagonals to try the next branch
                    cols[col] = false
                    diags[diagIndex] = false
                    antiDiags[antiDiagIndex] = false
                }
            }
        }

        // Start the recursion at the first row
        backtrack(row: 0)
        return count
    }
}