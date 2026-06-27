// 2448. Minimum Cost to Make Array Equal
// https://leetcode.com/problems/minimum-cost-to-make-array-equal
//
// Time Complexity: O(N log N)
// Space Complexity: O(N)
//
// Explanation:
// We can find the optimal target value by finding the weighted median of the `nums` array, where the weights are given by the `cost` array.
// First, we pair each number with its corresponding cost and sort the pairs based on the numbers.
// The optimal target is the number at which the cumulative cost reaches or exceeds half of the total cost.
// Once we find this target (weighted median), we calculate the total cost to make all elements equal to this target.
// Sorting takes O(N log N) time, and finding the median/calculating cost takes O(N) time. Storing pairs takes O(N) space.

class Solution {
    func minCost(_ nums: [Int], _ cost: [Int]) -> Int {
        let n = nums.count
        var pairs = [(num: Int, cost: Int)]()
        var totalCost = 0
        
        for i in 0..<n {
            pairs.append((nums[i], cost[i]))
            totalCost += cost[i]
        }
        
        // Sort pairs by nums
        pairs.sort { $0.num < $1.num }
        
        var currentCost = 0
        var median = 0
        
        // Find the weighted median
        for i in 0..<n {
            currentCost += pairs[i].cost
            if currentCost >= (totalCost + 1) / 2 {
                median = pairs[i].num
                break
            }
        }
        
        // Calculate the total cost to make all numbers equal to the median
        var ans = 0
        for i in 0..<n {
            ans += abs(nums[i] - median) * cost[i]
        }
        
        return ans
    }
}
