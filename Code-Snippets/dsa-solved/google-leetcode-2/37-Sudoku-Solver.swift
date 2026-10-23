// 37. Sudoku Solver
// https://leetcode.com/problems/sudoku-solver

/*
 Intuition/Explanation:
 This is a classic backtracking problem. We traverse the board cell by cell.
 For each empty cell ('.'), we try placing digits '1' through '9'.
 To ensure validity, we check if the digit already exists in the same row, column, or 3x3 sub-box.
 If valid, we place the digit and recursively attempt to solve the rest of the board.
 If it leads to a valid solution, we return true. If not, we backtrack (reset the cell to '.') 
 and try the next possible digit.

 Time Complexity: O(9^(81)), but practically much faster due to early pruning. 
 In the worst case, for each empty cell we have 9 choices, and there are at most 81 empty cells.
 Space Complexity: O(81) for the recursion stack depth (since there are at most 81 empty cells). 
 The board is modified in-place, taking O(1) auxiliary space.
*/

class Solution {
    func solveSudoku(_ board: inout [[Character]]) {
        _ = solve(&board)
    }
    
    private func solve(_ board: inout [[Character]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == "." {
                    // Try all possible digits
                    for digit in "123456789" {
                        if isValid(board, row, col, digit) {
                            board[row][col] = digit
                            
                            // Recursively solve the rest of the board
                            if solve(&board) {
                                return true
                            }
                            
                            // Backtrack if placing `digit` didn't lead to a solution
                            board[row][col] = "."
                        }
                    }
                    // If no digit from '1' to '9' is valid, the current path is wrong
                    return false
                }
            }
        }
        // All cells are filled correctly
        return true
    }
    
    private func isValid(_ board: [[Character]], _ row: Int, _ col: Int, _ digit: Character) -> Bool {
        let subBoxStartRow = (row / 3) * 3
        let subBoxStartCol = (col / 3) * 3
        
        for i in 0..<9 {
            // Check row
            if board[row][i] == digit { return false }
            // Check column
            if board[i][col] == digit { return false }
            // Check 3x3 sub-box
            let r = subBoxStartRow + i / 3
            let c = subBoxStartCol + i % 3
            if board[r][c] == digit { return false }
        }
        
        return true
    }
}
