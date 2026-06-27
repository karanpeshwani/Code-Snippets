// 327. Count of Range Sum
// https://leetcode.com/problems/count-of-range-sum/
//
// Time Complexity: O(N log N), where N is the length of the array. We use a divide-and-conquer approach (Merge Sort) on the prefix sum array. The work done at each level of the recursion tree is O(N) for finding valid ranges and merging, and there are log N levels.
// Space Complexity: O(N), for storing the prefix sum array and the temporary array used during the merge step.

class Solution {
    func countRangeSum(_ nums: [Int], _ lower: Int, _ upper: Int) -> Int {
        // Calculate prefix sums where prefixSums[i] is the sum of nums[0..<i]
        var prefixSums = [Int](repeating: 0, count: nums.count + 1)
        for i in 0..<nums.count {
            prefixSums[i + 1] = prefixSums[i] + nums[i]
        }
        
        var temp = [Int](repeating: 0, count: prefixSums.count)
        
        // Helper function to perform merge sort and count valid range sums
        func mergeSort(_ left: Int, _ right: Int) -> Int {
            if left >= right {
                return 0
            }
            
            let mid = left + (right - left) / 2
            var count = mergeSort(left, mid) + mergeSort(mid + 1, right)
            
            var j = mid + 1
            var k = mid + 1
            
            // Count valid range sums crossing the mid point
            // Since the left and right halves are sorted, we can use two pointers (j, k)
            for i in left...mid {
                while j <= right && prefixSums[j] - prefixSums[i] < lower {
                    j += 1
                }
                while k <= right && prefixSums[k] - prefixSums[i] <= upper {
                    k += 1
                }
                count += (k - j)
            }
            
            // Standard merge step to maintain sorted order
            var p1 = left
            var p2 = mid + 1
            var p = left
            
            while p1 <= mid && p2 <= right {
                if prefixSums[p1] <= prefixSums[p2] {
                    temp[p] = prefixSums[p1]
                    p1 += 1
                } else {
                    temp[p] = prefixSums[p2]
                    p2 += 1
                }
                p += 1
            }
            
            while p1 <= mid {
                temp[p] = prefixSums[p1]
                p1 += 1
                p += 1
            }
            
            while p2 <= right {
                temp[p] = prefixSums[p2]
                p2 += 1
                p += 1
            }
            
            // Copy back the sorted elements
            for i in left...right {
                prefixSums[i] = temp[i]
            }
            
            return count
        }
        
        return mergeSort(0, prefixSums.count - 1)
    }
}
