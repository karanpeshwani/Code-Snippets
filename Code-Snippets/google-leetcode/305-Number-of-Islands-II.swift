// 305-Number-of-Islands-II.swift
// 305. Number of Islands II
// https://leetcode.com/problems/number-of-islands-ii/
//
// Time Complexity: O(k * alpha(mn)) where k is the number of positions. We use Union-Find with path compression.
// alpha(mn) => inverse Ackermann function. It is almost constant for any value.
// Space Complexity: O(m * n) for the Union-Find parent array.

class Solution {
    func numIslands2(_ m: Int, _ n: Int, _ positions: [[Int]]) -> [Int] {
        var parent = Array(repeating: -1, count: m * n)
        var count = 0
        var res = [Int]()
        
        let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        func find(_ i: Int) -> Int {
            if parent[i] == i {
                return i
            }
            parent[i] = find(parent[i])
            return parent[i]
        }
        
        for pos in positions {
            let r = pos[0]
            let c = pos[1]
            let idx = r * n + c
            
            // If already land, just append current count
            if parent[idx] != -1 {
                res.append(count)
                continue
            }
            
            parent[idx] = idx
            count += 1
            
            for d in dirs {
                let nr = r + d.0
                let nc = c + d.1
                let nidx = nr * n + nc
                
                // Check if neighbor is within bounds and is land
                if nr >= 0 && nr < m && nc >= 0 && nc < n && parent[nidx] != -1 {
                    let root1 = find(idx)
                    let root2 = find(nidx)
                    
                    if root1 != root2 {
                        parent[root1] = root2
                        count -= 1 // merge two islands
                    }
                }
            }
            res.append(count)
        }
        return res
    }
}
