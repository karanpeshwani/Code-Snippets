// 2290. Minimum Obstacle Removal to Reach Corner
// https://leetcode.com/problems/minimum-obstacle-removal-to-reach-corner/
//
// Time Complexity: O(m * n), where m is the number of rows and n is the number of columns.
// We use 0-1 BFS because the edge weights are either 0 (empty cell) or 1 (obstacle). 
// Each cell is processed at most once.
// Space Complexity: O(m * n) to store the deque and the distances array.

import Collections

class Solution {
    func minimumObstacles(_ grid: [[Int]]) -> Int {
        let m = grid.count
        let n = grid[0].count
        
        // Deque for 0-1 BFS. Stores tuples of (row, col, obstacles_removed)
        var deque = Deque<(Int, Int, Int)>()
        deque.append((0, 0, 0))
        
        // Distance array to keep track of minimum obstacles removed to reach each cell
        // Initialized with a large value (Int.max)
        var distances = Array(repeating: Array(repeating: Int.max, count: n), count: m)
        distances[0][0] = 0
        
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        
        while let (row, col, obstaclesRemoved) = deque.popFirst() {
            // If we reached the bottom-right corner, return the obstacles removed
            if row == m - 1 && col == n - 1 {
                return obstaclesRemoved
            }
            
            // Optimization: If we found a shorter path previously, skip
            if distances[row][col] < obstaclesRemoved {
                continue
            }
            
            for (dr, dc) in directions {
                let newRow = row + dr
                let newCol = col + dc
                
                if newRow >= 0 && newRow < m && newCol >= 0 && newCol < n {
                    let weight = grid[newRow][newCol]
                    let newObstaclesRemoved = obstaclesRemoved + weight
                    
                    // If we found a path with fewer obstacles removed
                    if newObstaclesRemoved < distances[newRow][newCol] {
                        distances[newRow][newCol] = newObstaclesRemoved
                        
                        // 0-1 BFS logic: 
                        // If weight is 0 (no obstacle), append to front (higher priority to process first)
                        // If weight is 1 (obstacle), append to back (lower priority)
                        if weight == 0 {
                            deque.prepend((newRow, newCol, newObstaclesRemoved))
                        } else {
                            deque.append((newRow, newCol, newObstaclesRemoved))
                        }
                    }
                }
            }
        }
        
        return -1
    }
}
