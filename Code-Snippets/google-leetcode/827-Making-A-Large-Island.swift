// 827-Making-A-Large-Island.swift
// 827. Making A Large Island
// https://leetcode.com/problems/making-a-large-island/
//
// Time Complexity: O(N^2) where N is the length of the grid. We do a DFS to find the area of each island, then we check each 0 to see what islands it connects.
// Space Complexity: O(N^2) for DFS recursion stack and island ID mapping.

class Solution {
    func largestIsland(_ grid: [[Int]]) -> Int {
        let n = grid.count
        var grid = grid
        var islandArea = [Int: Int]()
        var islandId = 2
        var maxArea = 0
        let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        func dfs(_ r: Int, _ c: Int, _ id: Int) -> Int {
            if r < 0 || r >= n || c < 0 || c >= n || grid[r][c] != 1 {
                return 0
            }
            grid[r][c] = id
            var area = 1
            for d in dirs {
                area += dfs(r + d.0, c + d.1, id)
            }
            return area
        }
        
        for r in 0..<n {
            for c in 0..<n {
                if grid[r][c] == 1 {
                    let area = dfs(r, c, islandId)
                    islandArea[islandId] = area
                    maxArea = max(maxArea, area)
                    islandId += 1
                }
            }
        }
        
        for r in 0..<n {
            for c in 0..<n {
                if grid[r][c] == 0 {
                    var connectedIslands = Set<Int>()
                    var area = 1
                    for d in dirs {
                        let nr = r + d.0
                        let nc = c + d.1
                        if nr >= 0 && nr < n && nc >= 0 && nc < n && grid[nr][nc] > 1 {
                            connectedIslands.insert(grid[nr][nc])
                        }
                    }
                    for id in connectedIslands {
                        area += islandArea[id]!
                    }
                    maxArea = max(maxArea, area)
                }
            }
        }
        
        return maxArea == 0 ? 1 : maxArea // if maxArea == 0, grid was all 0s, turning one 0 to 1 gives 1
    }
}
