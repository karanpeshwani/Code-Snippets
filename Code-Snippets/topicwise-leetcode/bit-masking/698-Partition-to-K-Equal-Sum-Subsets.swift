// 698. Partition to K Equal Sum Subsets
// https://leetcode.com/problems/partition-to-k-equal-sum-subsets/

/*
 Intuition:
 We need to partition the array into `k` subsets that all have the exact same sum.
 The target sum for each subset must be `totalSum / k`. If the total sum is not divisible by `k`, it's impossible.
 We can use Depth First Search (DFS) with backtracking to try and build these `k` subsets one by one.
 To optimize the search:
 1. Sort the numbers in descending order to place larger numbers first (fails faster if impossible).
 2. Keep track of which elements have been used using a bitmask (since N <= 16).
 3. Once a subset reaches the `target` sum, recursively start building the next subset from the beginning.
 4. We can use a `memo` dictionary to cache visited bitmasks to avoid redundant calculations.

 Time Complexity: O(k * 2^N)
 - In the worst case, we might explore many combinations. 
 - With memoization on the bitmask, we compute the result for each of the 2^N states at most once.
 - Total time complexity is O(k * 2^N) or O(N * 2^N) depending on implementation details.

 Space Complexity: O(2^N)
 - We use a dictionary to memoize the states (up to 2^N states).
 - The recursion stack can go up to N deep.
 - Overall space complexity is O(2^N) due to memoization.
 */

class Solution {
    func canPartitionKSubsets(_ nums: [Int], _ k: Int) -> Bool {
        let totalSum = nums.reduce(0, +)
        if totalSum % k != 0 { return false }
        
        let target = totalSum / k
        let sortedNums = nums.sorted(by: >)
        
        // If the largest number is greater than target, impossible
        if sortedNums[0] > target { return false }
        
        var memo = [Int: Bool]()
        
        func dfs(mask: Int, currentSum: Int, subsetsRemaining: Int, startIdx: Int) -> Bool {
            if subsetsRemaining == 0 { return true }
            
            if currentSum == target {
                // Successfully formed a subset, move on to the next one
                let result = dfs(mask: mask, currentSum: 0, subsetsRemaining: subsetsRemaining - 1, startIdx: 0)
                memo[mask] = result
                return result
            }
            
            if let cached = memo[mask] { return cached }
            
            for i in startIdx..<sortedNums.count {
                // If the element is not used and adding it doesn't exceed target
                if (mask & (1 << i)) == 0 && currentSum + sortedNums[i] <= target {
                    if dfs(mask: mask | (1 << i), currentSum: currentSum + sortedNums[i], subsetsRemaining: subsetsRemaining, startIdx: i + 1) {
                        return true
                    }
                }
            }
            
            memo[mask] = false
            return false
        }
        
        return dfs(mask: 0, currentSum: 0, subsetsRemaining: k, startIdx: 0)
    }
}
