// 1293. Shortest Path in a Grid with Obstacles Elimination
// https://leetcode.com/problems/shortest-path-in-a-grid-with-obstacles-elimination/
// 
// Time Complexity: O(m * n * k), where m is the number of rows, n is the number of columns, 
// and k is the number of obstacles we can eliminate. In the worst-case scenario, we might 
// visit every cell for every possible number of obstacles eliminated.
// Space Complexity: O(m * n * k) to store the visited states and the queue for BFS.

import Collections

class Solution {
    func shortestPath(_ grid: [[Int]], _ k: Int) -> Int {
        let m = grid.count
        let n = grid[0].count
        
        // Optimization: If we can eliminate enough obstacles to take the shortest Manhattan distance path
        // directly to the target, we return the Manhattan distance.
        if k >= m + n - 2 {
            return m + n - 2
        }
        
        // Queue stores tuples of (row, col, remaining_k, steps)
        var queue = Deque<(Int, Int, Int, Int)>()
        queue.append((0, 0, k, 0))
        
        // Visited array to store the maximum 'k' remaining at each cell to avoid redundant visits.
        // We initialize with -1. If we reach a cell with a larger 'k', it means we found a better 
        // path to this cell, so we can explore it again.
        var visited = Array(repeating: Array(repeating: -1, count: n), count: m)
        visited[0][0] = k
        
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        
        while let (row, col, remainingK, steps) = queue.popFirst() {
            // Reached destination
            if row == m - 1 && col == n - 1 {
                return steps
            }
            
            for (dr, dc) in directions {
                let newRow = row + dr
                let newCol = col + dc
                
                if newRow >= 0 && newRow < m && newCol >= 0 && newCol < n {
                    let newK = remainingK - grid[newRow][newCol]
                    
                    // If we have enough k to pass, and it provides a better state (more remaining k)
                    if newK >= 0 && newK > visited[newRow][newCol] {
                        visited[newRow][newCol] = newK
                        queue.append((newRow, newCol, newK, steps + 1))
                    }
                }
            }
        }
        
        return -1
    }
}
