// 1349. Maximum Students Taking Exam
// https://leetcode.com/problems/maximum-students-taking-exam

/*
 Intuition:
 We need to place the maximum number of students on seats such that no two students can cheat.
 The constraints are small: m <= 8 (rows) and n <= 8 (columns).
 This suggests a Dynamic Programming approach with Bitmasking.
 We can process the classroom row by row. For a specific row, a binary mask of length `n` can represent
 the student seating arrangement (1 for student, 0 for empty).
 
 A mask is valid for the current row if:
 1. It only occupies available seats (no broken seats).
 2. It has no adjacent students (no two 1s are next to each other).
 
 A mask is compatible with the previous row's mask if:
 - No student in the current row can see the paper of a student in the previous row diagonally.
 
 Let `dp[i][mask]` be the maximum students seated in the first `i` rows with the `i`-th row having arrangement `mask`.
 `dp[i][mask] = max(dp[i-1][prev_mask]) + count(mask)` for all compatible `prev_mask`.

 Time Complexity: O(M * 3^N) or O(M * 2^N * 2^N)
 - M is the number of rows, N is the number of columns (M, N <= 8).
 - For each row, we iterate through all possible current masks (2^N).
 - For each current mask, we iterate through all possible previous masks (2^N).
 - Overall time complexity is well within time limits since 8 * 256 * 256 is around 5.2 * 10^5 operations.

 Space Complexity: O(M * 2^N) or O(2^N)
 - The DP table requires space for each row and each mask.
 - We can optimize this by only keeping the DP array from the previous row.
 - Overall space complexity is O(2^N).
 */

class Solution {
    func maxStudents(_ seats: [[Character]]) -> Int {
        let m = seats.count
        let n = seats[0].count
        
        // Precompute valid seats for each row as a bitmask
        var validSeats = Array(repeating: 0, count: m)
        for r in 0..<m {
            var mask = 0
            for c in 0..<n {
                if seats[r][c] == "." {
                    mask |= (1 << c)
                }
            }
            validSeats[r] = mask
        }
        
        // Helper function to count set bits
        func countSetBits(_ n: Int) -> Int {
            var count = 0
            var num = n
            while num > 0 {
                count += num & 1
                num >>= 1
            }
            return count
        }
        
        // dp[mask] stores max students for the previous row
        var dp = Array(repeating: -1, count: 1 << n)
        dp[0] = 0 // Base case: 0 students, mask 0
        
        for r in 0..<m {
            var nextDp = Array(repeating: -1, count: 1 << n)
            
            for currentMask in 0..<(1 << n) {
                // 1. Check if current mask only uses available seats
                if (currentMask & validSeats[r]) != currentMask {
                    continue
                }
                
                // 2. Check for no adjacent students in the same row
                if (currentMask & (currentMask >> 1)) != 0 {
                    continue
                }
                
                let studentsInCurrentRow = countSetBits(currentMask)
                
                // 3. Find compatible previous row masks
                for prevMask in 0..<(1 << n) {
                    if dp[prevMask] == -1 {
                        continue
                    }
                    
                    // Check for diagonal conflicts
                    // Current mask shifted left or right should not intersect with prevMask
                    if (currentMask >> 1) & prevMask != 0 || (currentMask << 1) & prevMask != 0 {
                        continue
                    }
                    
                    nextDp[currentMask] = max(nextDp[currentMask], dp[prevMask] + studentsInCurrentRow)
                }
            }
            dp = nextDp
        }
        
        return dp.max() ?? 0
    }
}
