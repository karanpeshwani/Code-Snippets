// 312. Burst Balloons
// Link: https://leetcode.com/problems/burst-balloons/
//
// Time Complexity: O(N^3), where N is the number of balloons.
// Explanation: There are O(N^2) possible states (subarrays defined by left and right pointers).
// For each state, we iterate through up to N possible balloons to burst last.
// Space Complexity: O(N^2)
// Explanation: The memoization table stores the maximum coins for every possible subarray of balloons,
// plus the recursion call stack which goes up to O(N) deep.

class Solution {
    func maxCoins(_ nums: [Int]) -> Int {
        // Pad the array with 1s to handle the boundaries gracefully
        var balloons = [1]
        balloons.append(contentsOf: nums)
        balloons.append(1)

        let n = balloons.count

        // memo[i][j] represents the max coins obtained by bursting balloons strictly between indices i and j.
        // We initialize with -1 to differentiate between an uncomputed state and a computed state that yields 0 coins.
        var memo = Array(repeating: Array(repeating: -1, count: n), count: n)

        // Helper recursive function
        func burst(_ left: Int, _ right: Int) -> Int {
            // Base case: If there are no balloons strictly between left and right, we can't burst anything.
            if left + 1 >= right {
                return 0
            }

            // If we have already computed this subproblem, return the cached result.
            if memo[left][right] != -1 {
                return memo[left][right]
            }

            var maxCoins = 0

            // i is the balloon we choose to burst LAST in the range (left, right)
            for i in (left + 1)..<right {
                let coins = balloons[left] * balloons[i] * balloons[right]
                // Recursively solve for the left and right subproblems
                let totalCoins = coins + burst(left, i) + burst(i, right)
                maxCoins = max(maxCoins, totalCoins)
            }

            // Cache the result before returning
            memo[left][right] = maxCoins
            return maxCoins
        }

        // We want the max coins obtained by bursting balloons strictly between the padded 1s
        return burst(0, n - 1)
    }
}