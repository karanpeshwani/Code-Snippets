// 2448. Minimum Cost to Make Array Equal
// https://leetcode.com/problems/minimum-cost-to-make-array-equal

/*
 Approach 1: Binary Search
 Time Complexity: O(N log K) where K is the range of values in `nums`
 Space Complexity: O(1)
 
 Explanation:
 The total cost is a convex function (monotonically descending to a single minimum, then ascending).
 For a given point `m`, we compute the cost for it and its neighbor `m + 1`. 
 By comparing those costs, we can tell whether the minimum is on the left or on the right.
 We binary-search for that minimum within the range of `min(nums)` to `max(nums)`.

 Approach 2: Weighted Median (Sorting)
 Time Complexity: O(N log N)
 Space Complexity: O(N)

 Explanation:
 We can find the optimal target value by finding the weighted median of the `nums` array, where the weights are given by the `cost` array.
 First, we pair each number with its corresponding cost and sort the pairs based on the numbers.
 The optimal target is the number at which the cumulative cost reaches or exceeds half of the total cost.
 Once we find this target (weighted median), we calculate the total cost to make all elements equal to this target.
 Sorting takes O(N log N) time, and finding the median/calculating cost takes O(N) time. Storing pairs takes O(N) space.
*/

class Solution {

    // Approach 1: Binary Search
    func minCost(_ nums: [Int], _ cost: [Int]) -> Int {
        var l = nums.min() ?? 1
        var r = nums.max() ?? 1_000_000
        var res = 0
        var res1 = 0

        while l < r {
            let m = l + (r - l) / 2
            res = 0
            res1 = 0

            for i in 0..<nums.count {
                res += cost[i] * abs(nums[i] - m)
                res1 += cost[i] * abs(nums[i] - (m + 1))
            }

            if res < res1 {
                r = m
            } else {
                l = m + 1
            }
        }

        return min(res, res1)
    }


    // Approach 2: Weighted Median (Sorting)
    func minCostWeightedMedian(_ nums: [Int], _ cost: [Int]) -> Int {
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
