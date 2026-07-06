// 51. N-Queens
// https://leetcode.com/problems/n-queens
//
// Intuition/Explanation:
// This problem can be solved using backtracking. We place queens row by row.
// To efficiently check if a cell is under attack, we use sets to track:
// - Occupied columns.
// - Positive diagonals (row + col is constant for each positive diagonal).
// - Negative diagonals (row - col is constant for each negative diagonal).
// For a given row, we try all columns. If placing a queen is safe (not in our sets), 
// we update our sets and recurse to the next row.
// Once `n` rows are processed, a valid configuration is found, which we format and store in the result array.
//
// Time Complexity: O(N!), where N is the number of queens. The number of choices decreases as we place queens.
// Space Complexity: O(N) to track columns, diagonals, and the current board configuration in the recursion stack.

class Solution {
    func solveNQueens(_ n: Int) -> [[String]] {
        var results = [[String]]()
        var cols = Set<Int>()
        var posDiags = Set<Int>() // row + col
        var negDiags = Set<Int>() // row - col
        var board = Array(repeating: Array(repeating: Character("."), count: n), count: n)
        
        func backtrack(_ row: Int) {
            // Base case: all queens placed
            if row == n {
                let formattedBoard = board.map { String($0) }
                results.append(formattedBoard)
                return
            }
            
            for col in 0..<n {
                // Check if the current position is safe
                if cols.contains(col) || posDiags.contains(row + col) || negDiags.contains(row - col) {
                    continue
                }
                
                // Place the queen
                cols.insert(col)
                posDiags.insert(row + col)
                negDiags.insert(row - col)
                board[row][col] = "Q"
                
                // Recurse to next row
                backtrack(row + 1)
                
                // Remove the queen (backtrack)
                cols.remove(col)
                posDiags.remove(row + col)
                negDiags.remove(row - col)
                board[row][col] = "."
            }
        }
        
        backtrack(0)
        return results
    }
}
