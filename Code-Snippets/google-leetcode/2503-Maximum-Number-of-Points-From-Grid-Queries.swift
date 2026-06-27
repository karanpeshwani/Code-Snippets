// 2503-Maximum-Number-of-Points-From-Grid-Queries.swift
// 2503. Maximum Number of Points From Grid Queries
// https://leetcode.com/problems/maximum-number-of-points-from-grid-queries/
//
// Time Complexity: O(M * N * log(M * N) + Q log Q) where M, N are dimensions of the grid, and Q is the number of queries.
// Space Complexity: O(M * N + Q) for the priority queue and result array.

import Collections

class Solution {
    func maxPoints(_ grid: [[Int]], _ queries: [Int]) -> [Int] {
        let m = grid.count
        let n = grid[0].count
        let k = queries.count
        
        // Sort queries while remembering their original indices
        var sortedQueries = [(val: Int, idx: Int)]()
        for (i, q) in queries.enumerated() {
            sortedQueries.append((q, i))
        }
        sortedQueries.sort { $0.val < $1.val }
        
        var res = Array(repeating: 0, count: k)
        var minHeap = Heap<Node>()
        var visited = Array(repeating: Array(repeating: false, count: n), count: m)
        
        struct Node: Comparable {
            let val: Int
            let r: Int
            let c: Int
            
            static func < (lhs: Node, rhs: Node) -> Bool {
                return lhs.val < rhs.val
            }
        }
        
        minHeap.insert(Node(val: grid[0][0], r: 0, c: 0))
        visited[0][0] = true
        var points = 0
        let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        for query in sortedQueries {
            while !minHeap.isEmpty && minHeap.min!.val < query.val {
                let curr = minHeap.removeMin()
                points += 1
                
                for d in dirs {
                    let nr = curr.r + d.0
                    let nc = curr.c + d.1
                    
                    if nr >= 0 && nr < m && nc >= 0 && nc < n && !visited[nr][nc] {
                        visited[nr][nc] = true
                        minHeap.insert(Node(val: grid[nr][nc], r: nr, c: nc))
                    }
                }
            }
            res[query.idx] = points
        }
        
        return res
    }
}
