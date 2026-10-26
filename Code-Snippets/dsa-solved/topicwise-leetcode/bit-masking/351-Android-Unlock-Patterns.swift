// 351. Android Unlock Patterns
// https://leetcode.com/problems/android-unlock-patterns/

/*
 Intuition:
 The problem asks for the number of valid android unlock patterns of length between m and n.
 The grid is 3x3 (keys 1 to 9). A move from key A to key B is valid if they are adjacent, 
 or if the line connecting them passes through a key that has already been visited.
 We can precompute the "jump" keys for all pairs (e.g., jump from 1 to 3 requires 2).
 We use Depth First Search (DFS) with backtracking to count all valid paths of length m to n.
 A bitmask is used to keep track of visited keys efficiently. 
 To optimize, we can use the symmetry of the grid:
 - The number of valid patterns starting from corners (1, 3, 7, 9) are identical.
 - The number of valid patterns starting from edge centers (2, 4, 6, 8) are identical.
 - The center (5) is unique.

 Time Complexity: O(9!)
 - In the worst case, we explore all possible permutations of the 9 keys.
 - The total number of valid patterns is relatively small (less than 9!), so it runs very fast.
 - Total time complexity is bounded by O(9!).

 Space Complexity: O(1)
 - We use a 2D array of size 10x10 to store the jump requirements, which takes O(1) space.
 - The recursion depth is at most 9, which takes O(1) space on the call stack.
 - We use a single integer (bitmask) to keep track of visited keys.
 - Overall space complexity is O(1).
 */

class Solution {
    func numberOfPatterns(_ m: Int, _ n: Int) -> Int {
        var jumps = Array(repeating: Array(repeating: 0, count: 10), count: 10)
        
        // Precompute the required intermediate keys for jumps across the grid
        jumps[1][3] = 2; jumps[3][1] = 2
        jumps[4][6] = 5; jumps[6][4] = 5
        jumps[7][9] = 8; jumps[9][7] = 8
        jumps[1][7] = 4; jumps[7][1] = 4
        jumps[2][8] = 5; jumps[8][2] = 5
        jumps[3][9] = 6; jumps[9][3] = 6
        jumps[1][9] = 5; jumps[9][1] = 5
        jumps[3][7] = 5; jumps[7][3] = 5
        
        var count = 0
        
        // DFS function to count valid paths
        func dfs(current: Int, length: Int, visitedMask: Int) {
            if length >= m {
                count += 1
            }
            if length == n {
                return
            }
            
            for nextKey in 1...9 {
                // If nextKey is not visited
                if (visitedMask & (1 << nextKey)) == 0 {
                    let requiredKey = jumps[current][nextKey]
                    
                    // Valid if no intermediate key is required, or the required key is already visited
                    if requiredKey == 0 || (visitedMask & (1 << requiredKey)) != 0 {
                        dfs(current: nextKey, length: length + 1, visitedMask: visitedMask | (1 << nextKey))
                    }
                }
            }
        }
        
        // Start from corner (1), multiply by 4 for symmetry (1, 3, 7, 9)
        let count1 = {
            count = 0
            dfs(current: 1, length: 1, visitedMask: (1 << 1))
            return count
        }()
        
        // Start from edge (2), multiply by 4 for symmetry (2, 4, 6, 8)
        let count2 = {
            count = 0
            dfs(current: 2, length: 1, visitedMask: (1 << 2))
            return count
        }()
        
        // Start from center (5)
        let count5 = {
            count = 0
            dfs(current: 5, length: 1, visitedMask: (1 << 5))
            return count
        }()
        
        return count1 * 4 + count2 * 4 + count5
    }
}
