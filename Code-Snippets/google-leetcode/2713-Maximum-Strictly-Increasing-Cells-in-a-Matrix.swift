// 2713. Maximum Strictly Increasing Cells in a Matrix
// https://leetcode.com/problems/maximum-strictly-increasing-cells-in-a-matrix

// Time Complexity: O(M * N * log(M * N)) where M is the number of rows and N is the number of columns.
// Finding unique values and sorting them takes O(K log K) time where K is the number of unique elements (K <= M*N).
// Processing each cell takes O(1) time, so the overall time is dominated by sorting.
// Space Complexity: O(M * N) for the dictionary to store coordinates of each value, and O(M + N) to maintain maxRow and maxCol arrays.

class Solution {
    func maxIncreasingCells(_ mat: [[Int]]) -> Int {
        let m = mat.count
        let n = mat[0].count
        
        // Map each distinct matrix value to an array of its cell coordinates (row, col)
        var valueToCells: [Int: [(Int, Int)]] = [:]
        for r in 0..<m {
            for c in 0..<n {
                let val = mat[r][c]
                valueToCells[val, default: []].append((r, c))
            }
        }
        
        // Process values in strictly increasing order
        let sortedValues = valueToCells.keys.sorted()
        
        // maxRow[i] stores the maximum path length ending in row i so far
        var maxRow = [Int](repeating: 0, count: m)
        // maxCol[j] stores the maximum path length ending in col j so far
        var maxCol = [Int](repeating: 0, count: n)
        
        var answer = 0
        
        for val in sortedValues {
            let cells = valueToCells[val]!
            var currentDp = [Int](repeating: 0, count: cells.count)
            
            // Step 1: Calculate the dp value for all cells with the current value.
            // This ensures we only use strictly smaller values' dp results (since we haven't updated maxRow/maxCol yet for this value).
            for i in 0..<cells.count {
                let r = cells[i].0
                let c = cells[i].1
                
                // The max path length to (r, c) is 1 plus the best we could do in its row or col from strictly smaller elements
                currentDp[i] = 1 + max(maxRow[r], maxCol[c])
                answer = max(answer, currentDp[i])
            }
            
            // Step 2: Update the maxRow and maxCol using the newly computed dp values
            for i in 0..<cells.count {
                let r = cells[i].0
                let c = cells[i].1
                
                maxRow[r] = max(maxRow[r], currentDp[i])
                maxCol[c] = max(maxCol[c], currentDp[i])
            }
        }
        
        return answer
    }
}
