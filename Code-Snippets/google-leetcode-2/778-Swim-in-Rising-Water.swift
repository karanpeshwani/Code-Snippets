// 778. Swim in Rising Water
// https://leetcode.com/problems/swim-in-rising-water

/*
 Intuition:
 We need to find a path from top-left (0,0) to bottom-right (N-1,N-1) such that the maximum
 elevation along the path is minimized. This is a classic bottleneck shortest path problem.
 We can solve this using Dijkstra's algorithm. We use a Min-Heap (Priority Queue) to always
 explore the cell that has the minimum maximum-elevation so far.
 We start at (0,0) with time = grid[0][0]. We expand to neighbors and update the time to
 reach them as `max(currentTime, grid[nr][nc])`. The heap ensures we always process the
 most promising (lowest max-elevation) path first.

 Time Complexity: O(N^2 log N)
 - The grid has N^2 cells. Each cell is pushed into and popped from the Min-Heap at most once.
 - Heap operations take O(log(N^2)) = O(log N).
 - Overall time complexity is O(N^2 log N).

 Space Complexity: O(N^2)
 - We use a boolean array to keep track of visited cells, taking O(N^2) space.
 - The Min-Heap can store up to O(N^2) elements.
 - Overall space complexity is O(N^2).
 */

import Collections

class Solution {
    struct Cell: Comparable {
        let maxElevation: Int
        let row: Int
        let col: Int
        
        static func < (lhs: Cell, rhs: Cell) -> Bool {
            return lhs.maxElevation < rhs.maxElevation
        }
    }
    
    func swimInWater(_ grid: [[Int]]) -> Int {
        let n = grid.count
        var minHeap = Heap<Cell>()
        var visited = Array(repeating: Array(repeating: false, count: n), count: n)
        
        minHeap.insert(Cell(maxElevation: grid[0][0], row: 0, col: 0))
        visited[0][0] = true
        
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        
        while let current = minHeap.popMin() {
            if current.row == n - 1 && current.col == n - 1 {
                return current.maxElevation
            }
            
            for dir in directions {
                let nr = current.row + dir.0
                let nc = current.col + dir.1
                
                if nr >= 0 && nr < n && nc >= 0 && nc < n && !visited[nr][nc] {
                    visited[nr][nc] = true
                    let newElevation = max(current.maxElevation, grid[nr][nc])
                    minHeap.insert(Cell(maxElevation: newElevation, row: nr, col: nc))
                }
            }
        }
        
        return -1
    }
}
