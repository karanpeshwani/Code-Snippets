// 689. Maximum Sum of 3 Non-Overlapping Subarrays
// https://leetcode.com/problems/maximum-sum-of-3-non-overlapping-subarrays/

/*
 Intuition:
 We need to find 3 non-overlapping subarrays of length `k` with the maximum sum.
 We can first compute the sum of all subarrays of length `k` using a sliding window. Let's store these sums in an array `windowSums`.
 Then, this problem reduces to finding three indices `i`, `j`, `l` such that `i + k <= j` and `j + k <= l` that maximize `windowSums[i] + windowSums[j] + windowSums[l]`.
 Since `j` is the middle subarray's starting index, it can range from `k` to `n - 2k`.
 For a fixed `j`, we want the maximum `windowSums[i]` (for `i` in `[0, j - k]`) and the maximum `windowSums[l]` (for `l` in `[j + k, n - k]`).
 We can precompute two arrays:
 - `leftMaxIndex`: the index of the maximum window sum in `[0, i]`
 - `rightMaxIndex`: the index of the maximum window sum in `[i, n - k]`
 Finally, we iterate through all possible middle indices `j`, and find the triplet `(leftMaxIndex[j - k], j, rightMaxIndex[j + k])` that gives the maximum total sum.
 If there are ties, the problem asks for the lexicographically smallest triplet, which is handled naturally by how we update `leftMaxIndex` and `rightMaxIndex`.

 Time Complexity: O(N)
 - N is the number of elements in the array.
 - Computing `windowSums` takes O(N).
 - Computing `leftMaxIndex` and `rightMaxIndex` takes O(N).
 - Iterating to find the best triplet takes O(N).
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - We use arrays of size N to store `windowSums`, `leftMaxIndex`, and `rightMaxIndex`.
 - Overall space complexity is O(N).
 */

class Solution {
    func maxSumOfThreeSubarrays(_ nums: [Int], _ k: Int) -> [Int] {
        let n = nums.count
        var windowSums = [Int](repeating: 0, count: n - k + 1)
        var currentSum = 0
        
        for i in 0..<n {
            currentSum += nums[i]
            if i >= k {
                currentSum -= nums[i - k]
            }
            if i >= k - 1 {
                windowSums[i - k + 1] = currentSum
            }
        }
        
        let windowCount = windowSums.count
        var leftMaxIndex = [Int](repeating: 0, count: windowCount)
        var rightMaxIndex = [Int](repeating: 0, count: windowCount)
        
        // Compute leftMaxIndex
        var bestLeft = 0
        for i in 0..<windowCount {
            if windowSums[i] > windowSums[bestLeft] {
                bestLeft = i
            }
            leftMaxIndex[i] = bestLeft
        }
        
        // Compute rightMaxIndex
        var bestRight = windowCount - 1
        for i in (0..<windowCount).reversed() {
            // >= ensures lexicographically smallest index when sums are equal
            if windowSums[i] >= windowSums[bestRight] {
                bestRight = i
            }
            rightMaxIndex[i] = bestRight
        }
        
        var maxSum = 0
        var result = [-1, -1, -1]
        
        // Iterate through all possible middle windows
        for j in k..<(windowCount - k) {
            let leftIdx = leftMaxIndex[j - k]
            let rightIdx = rightMaxIndex[j + k]
            
            let totalSum = windowSums[leftIdx] + windowSums[j] + windowSums[rightIdx]
            
            if totalSum > maxSum {
                maxSum = totalSum
                result = [leftIdx, j, rightIdx]
            }
        }
        
        return result
    }
}
