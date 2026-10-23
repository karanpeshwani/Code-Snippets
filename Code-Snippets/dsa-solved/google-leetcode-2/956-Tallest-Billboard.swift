// 956. Tallest Billboard
// https://leetcode.com/problems/tallest-billboard

/*
 Intuition:
 We need to divide a subset of rods into two groups such that their sums are equal, and the sum is maximized.
 Instead of keeping track of the exact lengths of the two supports, we only need to keep track of the
 difference between their lengths.
 Let `dp[diff]` be the maximum height of the taller support when the difference between the two supports is `diff`.
 For each rod, we have three choices:
 1. Don't use the rod (state remains same).
 2. Add the rod to the taller support. The new difference becomes `diff + rod`, and the taller support increases by `rod`.
 3. Add the rod to the shorter support.
    - If `rod <= diff`, the taller support remains the same, but the difference becomes `diff - rod`.
    - If `rod > diff`, the shorter support becomes the taller one. The new difference is `rod - diff`, and the taller support becomes the previous shorter support + `rod` = `(previous taller - diff) + rod`.
 We can maintain this `dp` dictionary/array and update it for each rod.

 Time Complexity: O(N * S)
 - N is the number of rods, and S is the maximum possible sum of all rods (at most 5000).
 - For each rod, we iterate over all possible differences (at most 5000).
 - Overall time complexity is O(N * S).

 Space Complexity: O(S)
 - The `dp` array stores the maximum taller support for each possible difference.
 - The size of this array is bounded by S + 1.
 - Overall space complexity is O(S).
 */

class Solution {
    func tallestBillboard(_ rods: [Int]) -> Int {
        // dp[diff] stores the max taller support height for a given difference
        var dp = [Int: Int]()
        dp[0] = 0 // Base case: difference 0, height 0
        
        for rod in rods {
            let currentDp = dp
            
            for (diff, taller) in currentDp {
                // Choice 1: Add to the taller support
                let newDiffTaller = diff + rod
                dp[newDiffTaller] = max(dp[newDiffTaller, default: 0], taller + rod)
                
                // Choice 2: Add to the shorter support
                let newDiffShorter = abs(diff - rod)
                let newTaller = max(taller, taller - diff + rod)
                dp[newDiffShorter] = max(dp[newDiffShorter, default: 0], newTaller)
            }
        }
        
        return dp[0, default: 0]
    }
}
