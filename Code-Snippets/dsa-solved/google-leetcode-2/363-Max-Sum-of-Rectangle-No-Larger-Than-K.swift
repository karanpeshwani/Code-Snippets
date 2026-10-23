// 363. Max Sum of Rectangle No Larger Than K
// https://leetcode.com/problems/max-sum-of-rectangle-no-larger-than-k

/*
 Intuition:
 To find the maximum sum of a rectangle no larger than k, we can convert the 2D problem
 into a 1D problem. We iterate over all possible pairs of left and right columns.
 For a fixed pair of left and right columns, we can compress the 2D subarray into a 1D
 array by summing the elements in each row between the left and right columns.
 Then, the problem reduces to finding the maximum contiguous subarray sum no larger than k
 in a 1D array.
 We can solve this 1D problem using a prefix sum and a sorted structure. Since Swift
 lacks a built-in TreeSet, we can maintain a sorted array of prefix sums and use binary
 search to find the smallest prefix sum that is >= `current_prefix_sum - k`.

 Time Complexity: O(C^2 * R log R)
 - We iterate over all pairs of columns, which takes O(C^2) time, where C is the number of columns.
 - For each pair, we iterate over the rows, calculate prefix sums, and binary search/insert into
   a sorted array. Binary search takes O(log R) and insertion takes O(R), leading to O(R^2) per 1D problem in the worst case, but practically optimized or bound by O(R log R) if a balanced BST was available.
 - Overall time complexity: O(C^2 * R^2) in Swift using Array insert, or O(C^2 * R log R) with a custom BST. We ensure C <= R by transposing if necessary to optimize.

 Space Complexity: O(R)
 - We use an array of size R to store the sums of rows for the current column bounds.
 - The sorted prefix sums array takes up to O(R) space.
 - Overall space complexity is O(R).
 */

class Solution {
    func maxSumSubmatrix(_ matrix: [[Int]], _ k: Int) -> Int {
        var matrix = matrix
        var rows = matrix.count
        var cols = matrix[0].count
        
        // Transpose the matrix if there are more rows than columns to optimize the outer loops
        if rows > cols {
            var newMatrix = Array(repeating: Array(repeating: 0, count: rows), count: cols)
            for r in 0..<rows {
                for c in 0..<cols {
                    newMatrix[c][r] = matrix[r][c]
                }
            }
            matrix = newMatrix
            swap(&rows, &cols)
        }
        
        var maxSum = Int.min
        
        for left in 0..<cols {
            var rowSums = Array(repeating: 0, count: rows)
            for right in left..<cols {
                for r in 0..<rows {
                    rowSums[r] += matrix[r][right]
                }
                
                // Find max subarray sum <= k in rowSums
                maxSum = max(maxSum, maxSumSubarray(rowSums, k))
                if maxSum == k {
                    return k // We can't do better than k
                }
            }
        }
        
        return maxSum
    }
    
    private func maxSumSubarray(_ arr: [Int], _ k: Int) -> Int {
        var maxSum = Int.min
        var currentSum = 0
        var prefixSums = [0] // Initialize with 0 to handle subarrays starting from index 0
        
        for num in arr {
            currentSum += num
            
            // We want to find the smallest prefix sum that is >= currentSum - k
            // equivalent to prefixSum >= currentSum - k
            let target = currentSum - k
            let index = binarySearch(prefixSums, target)
            
            if index < prefixSums.count {
                maxSum = max(maxSum, currentSum - prefixSums[index])
            }
            
            // Insert currentSum into prefixSums while maintaining sorted order
            insert(&prefixSums, currentSum)
        }
        
        return maxSum
    }
    
    // Binary search to find the first element >= target
    private func binarySearch(_ arr: [Int], _ target: Int) -> Int {
        var left = 0
        var right = arr.count
        
        while left < right {
            let mid = left + (right - left) / 2
            if arr[mid] < target {
                left = mid + 1
            } else {
                right = mid
            }
        }
        
        return left
    }
    
    // Insert element maintaining sorted order
    private func insert(_ arr: inout [Int], _ val: Int) {
        let index = binarySearch(arr, val)
        arr.insert(val, at: index)
    }
}
