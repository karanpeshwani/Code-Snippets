import Foundation
import Collections

/*
 Number of Connected Components

 Intuition:
 A connected component is a maximal set of vertices such that there is a path between every pair of vertices.
 To count them, we iterate through all nodes. Every time we encounter an unvisited node, it means we found a new component.
 We increment our counter and use BFS or DFS to traverse and mark the entire component as `visited`.

 Grid variations treat the matrix as a graph where each cell is a node, and edges exist between adjacent cells (up, down, left, right).

 Usecases & Usage Patterns:
 - Finding islands in a map/grid (e.g., "Number of Islands" problem on LeetCode).
 - Finding isolated clusters in social networks.
 - Image processing (connected-component labeling).

 Time Complexity:
 - Graph: O(V + E) (each node and edge visited once)
 - Grid: O(R * C) where R is rows and C is columns. Each cell and its 4 neighbors are processed.

 Space Complexity:
 - Graph: O(V) for visited array and Queue/Stack.
 - Grid: O(R * C) for visited array (or modifying input grid) and Queue/Stack.
*/

// MARK: - 1. In Graph (BFS & DFS)
class ConnectedComponentsGraph {
    func countComponentsBFS(V: Int, adj: [[Int]]) -> Int {
        var visited = Array(repeating: false, count: V)
        var count = 0
        
        func bfs(start: Int) {
            var queue: Deque<Int> = []
            queue.append(start)
            visited[start] = true
            
            while !queue.isEmpty {
                let node = queue.removeFirst()
                for neighbor in adj[node] {
                    if !visited[neighbor] {
                        visited[neighbor] = true
                        queue.append(neighbor)
                    }
                }
            }
        }
        
        for i in 0..<V {
            if !visited[i] {
                count += 1
                bfs(start: i)
            }
        }
        return count
    }
    
    func countComponentsDFS(V: Int, adj: [[Int]]) -> Int {
        var visited = Array(repeating: false, count: V)
        var count = 0
        
        func dfs(node: Int) {
            visited[node] = true
            for neighbor in adj[node] {
                if !visited[neighbor] {
                    dfs(node: neighbor)
                }
            }
        }
        
        for i in 0..<V {
            if !visited[i] {
                count += 1
                dfs(node: i)
            }
        }
        return count
    }
}

// MARK: - 2. In Grid (BFS & DFS)
class ConnectedComponentsGrid {
    let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)] // Right, Down, Left, Up
    
    // Example: count connected 1s (land)
    func numIslandsBFS(_ grid: [[Character]]) -> Int {
        if grid.isEmpty { return 0 }
        let rows = grid.count, cols = grid[0].count
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        var count = 0
        
        func bfs(r: Int, c: Int) {
            var queue: Deque<(Int, Int)> = []
            queue.append((r, c))
            visited[r][c] = true
            
            while !queue.isEmpty {
                let (currR, currC) = queue.removeFirst()
                
                for dir in directions {
                    let newR = currR + dir.0
                    let newC = currC + dir.1
                    
                    if newR >= 0, newR < rows, newC >= 0, newC < cols, 
                       grid[newR][newC] == "1", !visited[newR][newC] {
                        visited[newR][newC] = true
                        queue.append((newR, newC))
                    }
                }
            }
        }
        
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c] == "1" && !visited[r][c] {
                    count += 1
                    bfs(r: r, c: c)
                }
            }
        }
        return count
    }
    
    func numIslandsDFS(_ grid: [[Character]]) -> Int {
        if grid.isEmpty { return 0 }
        let rows = grid.count, cols = grid[0].count
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        var count = 0
        
        func dfs(r: Int, c: Int) {
            visited[r][c] = true
            
            for dir in directions {
                let newR = r + dir.0
                let newC = c + dir.1
                
                if newR >= 0, newR < rows, newC >= 0, newC < cols, 
                   grid[newR][newC] == "1", !visited[newR][newC] {
                    dfs(r: newR, c: newC)
                }
            }
        }
        
        for r in 0..<rows {
            for c in 0..<cols {
                if grid[r][c] == "1" && !visited[r][c] {
                    count += 1
                    dfs(r: r, c: c)
                }
            }
        }
        return count
    }
}
