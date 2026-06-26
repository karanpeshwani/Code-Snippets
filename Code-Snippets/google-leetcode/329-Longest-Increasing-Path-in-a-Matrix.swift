// 329. Longest Increasing Path in a Matrix
// Link: https://leetcode.com/problems/longest-increasing-path-in-a-matrix/
//
// Time Complexity: O(M * N), where M is the number of rows and N is the number of columns.
// Explanation: Thanks to memoization, each cell in the matrix is evaluated at most once. The DFS from a cell explores up to 4 neighbors in O(1) time.
// Space Complexity: O(M * N)
// Explanation: The memoization table requires O(M * N) space. The recursion call stack also requires up to O(M * N) space in the worst case.

class Solution {
    func longestIncreasingPath(_ matrix: [[Int]]) -> Int {
        if matrix.isEmpty || matrix[0].isEmpty { return 0 }
        
        let m = matrix.count
        let n = matrix[0].count
        var memo = Array(repeating: Array(repeating: 0, count: n), count: m)
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        
        func dfs(_ r: Int, _ c: Int) -> Int {
            if memo[r][c] != 0 { return memo[r][c] }
            
            var maxLength = 1
            for (dr, dc) in directions {
                let nr = r + dr
                let nc = c + dc
                
                if nr >= 0 && nr < m && nc >= 0 && nc < n && matrix[nr][nc] > matrix[r][c] {
                    maxLength = max(maxLength, 1 + dfs(nr, nc))
                }
            }
            
            memo[r][c] = maxLength
            return maxLength
        }
        
        var longestPath = 0
        for i in 0..<m {
            for j in 0..<n {
                longestPath = max(longestPath, dfs(i, j))
            }
        }
        
        return longestPath
    }
}
