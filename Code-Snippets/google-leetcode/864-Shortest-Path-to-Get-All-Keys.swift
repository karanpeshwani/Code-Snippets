// 864-Shortest-Path-to-Get-All-Keys.swift
// 864. Shortest Path to Get All Keys
// https://leetcode.com/problems/shortest-path-to-get-all-keys/
//
// Time Complexity: O(M * N * 2^K) where M and N are the grid dimensions and K is the number of keys. We do a BFS where states are (r, c, keysMask).
// Space Complexity: O(M * N * 2^K) to store the visited states and the BFS queue.

class Solution {
    func shortestPathAllKeys(_ grid: [String]) -> Int {
        let m = grid.count
        let n = grid[0].count
        var gridChars = [[Character]]()
        var startR = 0
        var startC = 0
        var k = 0
        
        for (i, row) in grid.enumerated() {
            let chars = Array(row)
            gridChars.append(chars)
            for j in 0..<n {
                let c = chars[j]
                if c == "@" {
                    startR = i
                    startC = j
                } else if c.isLowercase {
                    k += 1
                }
            }
        }
        
        let targetMask = (1 << k) - 1
        var queue = [(r: Int, c: Int, mask: Int, dist: Int)]()
        queue.append((startR, startC, 0, 0))
        
        var visited = Array(repeating: Array(repeating: Array(repeating: false, count: 1 << k), count: n), count: m)
        visited[startR][startC][0] = true
        
        let dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        var head = 0
        
        while head < queue.count {
            let (r, c, mask, dist) = queue[head]
            head += 1
            
            if mask == targetMask {
                return dist
            }
            
            for d in dirs {
                let nr = r + d.0
                let nc = c + d.1
                
                if nr >= 0 && nr < m && nc >= 0 && nc < n {
                    let char = gridChars[nr][nc]
                    if char == "#" { continue }
                    
                    var newMask = mask
                    if char.isLowercase {
                        let keyBit = Int(char.asciiValue! - Character("a").asciiValue!)
                        newMask |= (1 << keyBit)
                    }
                    
                    if char.isUppercase {
                        let lockBit = Int(char.asciiValue! - Character("A").asciiValue!)
                        if (newMask & (1 << lockBit)) == 0 {
                            continue // We don't have the key for this lock
                        }
                    }
                    
                    if !visited[nr][nc][newMask] {
                        visited[nr][nc][newMask] = true
                        queue.append((nr, nc, newMask, dist + 1))
                    }
                }
            }
        }
        
        return -1
    }
}
