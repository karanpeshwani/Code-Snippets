// 407. Trapping Rain Water II
// https://leetcode.com/problems/trapping-rain-water-ii

/*
 Intuition:
 This is a 2D version of Trapping Rain Water. We can imagine filling water from the borders inwards.
 The water level is determined by the lowest boundary. Thus, we can start from the outer boundary
 and always process the cell with the lowest height. We can use a Min-Heap (Priority Queue) to
 efficiently get the lowest boundary cell.
 We push all boundary cells into the min-heap and mark them as visited.
 Then, we repeatedly pop the lowest cell. For all its unvisited neighbors, if a neighbor's height
 is less than the current boundary height, it can trap water equal to the difference.
 We then push the neighbor into the min-heap with a height equal to the maximum of its own height
 and the current boundary height (because the water level has raised its effective height).

 Time Complexity: O(M * N * log(M * N))
 - We push M * N cells into the heap.
 - Each heap operation (insertion/extraction) takes O(log(M * N)) time.
 - Total time complexity is O(M * N * log(M * N)).

 Space Complexity: O(M * N)
 - The min-heap can store up to M * N elements.
 - A visited boolean matrix of size M x N is used.
 - Overall space complexity is O(M * N).
 */

import Collections

class Solution {
    struct Cell: Comparable {
        let row: Int
        let col: Int
        let height: Int
        
        static func < (lhs: Cell, rhs: Cell) -> Bool {
            return lhs.height < rhs.height
        }
    }
    
    func trapRainWater(_ heightMap: [[Int]]) -> Int {
        let m = heightMap.count
        guard m > 0 else { return 0 }
        let n = heightMap[0].count
        guard n > 0 else { return 0 }
        
        var visited = Array(repeating: Array(repeating: false, count: n), count: m)
        var minHeap = Heap<Cell>()
        
        // Push all boundary cells into the min-heap
        for i in 0..<m {
            minHeap.insert(Cell(row: i, col: 0, height: heightMap[i][0]))
            minHeap.insert(Cell(row: i, col: n - 1, height: heightMap[i][n - 1]))
            visited[i][0] = true
            visited[i][n - 1] = true
        }
        
        for j in 1..<(n - 1) {
            minHeap.insert(Cell(row: 0, col: j, height: heightMap[0][j]))
            minHeap.insert(Cell(row: m - 1, col: j, height: heightMap[m - 1][j]))
            visited[0][j] = true
            visited[m - 1][j] = true
        }
        
        let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        var waterTrapped = 0
        
        while let cell = minHeap.popMin() {
            for dir in directions {
                let newRow = cell.row + dir.0
                let newCol = cell.col + dir.1
                
                // Check if the neighbor is within bounds and not visited
                if newRow >= 0 && newRow < m && newCol >= 0 && newCol < n && !visited[newRow][newCol] {
                    visited[newRow][newCol] = true
                    
                    // If neighbor is shorter, it can trap water
                    if heightMap[newRow][newCol] < cell.height {
                        waterTrapped += cell.height - heightMap[newRow][newCol]
                    }
                    
                    // Push the neighbor into the heap with updated boundary height
                    minHeap.insert(Cell(row: newRow, col: newCol, height: max(cell.height, heightMap[newRow][newCol])))
                }
            }
        }
        
        return waterTrapped
    }
}
