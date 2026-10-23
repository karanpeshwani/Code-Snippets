// 1235. Maximum Profit in Job Scheduling
// https://leetcode.com/problems/maximum-profit-in-job-scheduling

/*
 Intuition:
 We want to find the maximum profit from a subset of non-overlapping jobs.
 This is a classic dynamic programming problem.
 First, we sort the jobs based on their end times. This allows us to process jobs sequentially and build the optimal solution.
 Let `dp[i]` be the maximum profit we can achieve using the first `i` jobs.
 For the `i`-th job, we have two choices:
 1. Don't schedule it: The profit is `dp[i-1]`.
 2. Schedule it: We add its profit to the maximum profit of the latest job that doesn't conflict with it
    (i.e., a job whose end time is <= the current job's start time). We can find this latest non-conflicting job efficiently using Binary Search.
 `dp[i] = max(dp[i-1], currentJob.profit + dp[latest_non_conflicting_job])`.

 Time Complexity: O(N log N)
 - Sorting the jobs takes O(N log N).
 - For each of the N jobs, we perform a binary search which takes O(log N).
 - Overall time complexity is O(N log N).

 Space Complexity: O(N)
 - We store the sorted jobs taking O(N) space.
 - The `dp` array stores the max profit up to each job, taking O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    struct Job {
        let start: Int
        let end: Int
        let profit: Int
    }
    
    func jobScheduling(_ startTime: [Int], _ endTime: [Int], _ profit: [Int]) -> Int {
        let n = startTime.count
        var jobs = [Job]()
        for i in 0..<n {
            jobs.append(Job(start: startTime[i], end: endTime[i], profit: profit[i]))
        }
        
        // Sort jobs by end time
        jobs.sort { $0.end < $1.end }
        
        // dp[i] stores the maximum profit using a subset of the first `i` jobs
        var dp = Array(repeating: 0, count: n)
        dp[0] = jobs[0].profit
        
        for i in 1..<n {
            // Option 1: Don't schedule current job
            var maxProfit = dp[i - 1]
            
            // Option 2: Schedule current job
            var currentProfit = jobs[i].profit
            
            // Binary search to find the latest job that doesn't conflict
            var left = 0
            var right = i - 1
            var latestNonConflicting = -1
            
            while left <= right {
                let mid = left + (right - left) / 2
                if jobs[mid].end <= jobs[i].start {
                    latestNonConflicting = mid
                    left = mid + 1
                } else {
                    right = mid - 1
                }
            }
            
            if latestNonConflicting != -1 {
                currentProfit += dp[latestNonConflicting]
            }
            
            dp[i] = max(maxProfit, currentProfit)
        }
        
        return dp[n - 1]
    }
}
