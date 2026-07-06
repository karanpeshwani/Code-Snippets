// 1568. Minimum Number of Days to Disconnect Island
// https://leetcode.com/problems/minimum-number-of-days-to-disconnect-island/

/*
 Intuition:
 The problem asks for the minimum number of days to disconnect an island (turn a grid of 1s into 0, >=2, or >0 disconnected islands).
 In one day, we can turn any land cell (1) into water (0).
 A key mathematical observation for this problem is that the answer is always 0, 1, or 2.
 Why? Because any corner or edge cell of a connected island has at most 2 neighbors. We can always disconnect a single cell
 by removing its (at most) 2 neighbors, resulting in at least 2 disconnected components (the single cell and the rest of the island).
 
 Thus, the algorithm is straightforward:
 1. Check if the grid is already disconnected (or has 0 islands). If so, return 0.
 2. Try removing each land cell (1) one by one and check if the grid becomes disconnected. If any single removal works, return 1.
 3. If neither 0 nor 1 works, the answer must be 2.

 We need a helper function `countIslands(grid)` to find the number of connected components using DFS or BFS.

 Time Complexity: O((M * N)^2)
 - Counting islands takes O(M * N) time.
 - In the worst case, we might have to check removing each of the M * N cells, and for each removal, count islands.
 - This leads to O(M * N) * O(M * N) = O((M * N)^2).
 - Since the maximum grid size is 30x30, (M * N)^2 is at most 810,000, which easily passes within the time limit.

 Space Complexity: O(M * N)
 - The DFS or BFS traversal requires an O(M * N) visited matrix or recursion stack.
 - Overall space complexity is O(M * N).
 */

class Solution {
    func minDays(_ grid: [[Int]]) -> Int {
        var grid = grid
        
        // Step 1: Check if already disconnected
        if countIslands(grid) != 1 {
            return 0
        }
        
        let m = grid.count
        let n = grid[0].count
        
        // Step 2: Try removing one land cell
        for r in 0..<m {
            for c in 0..<n {
                if grid[r][c] == 1 {
                    // Try removing this cell
                    grid[r][c] = 0
                    
                    if countIslands(grid) != 1 {
                        return 1
                    }
                    
                    // Backtrack and restore the cell
                    grid[r][c] = 1
                }
            }
        }
        
        // Step 3: If 0 and 1 don't work, the answer must be 2
        return 2
    }
    
    // Helper function to count the number of islands in the grid
    private func countIslands(_ grid: [[Int]]) -> Int {
        let m = grid.count
        let n = grid[0].count
        var visited = Array(repeating: Array(repeating: false, count: n), count: m)
        var count = 0
        
        func dfs(_ r: Int, _ c: Int) {
            if r < 0 || r >= m || c < 0 || c >= n || grid[r][c] == 0 || visited[r][c] {
                return
            }
            
            visited[r][c] = true
            
            dfs(r + 1, c)
            dfs(r - 1, c)
            dfs(r, c + 1)
            dfs(r, c - 1)
        }
        
        for r in 0..<m {
            for c in 0..<n {
                if grid[r][c] == 1 && !visited[r][c] {
                    count += 1
                    dfs(r, c)
                }
            }
        }
        
        return count
    }
}
