// 1671. Minimum Number of Removals to Make Mountain Array
// https://leetcode.com/problems/minimum-number-of-removals-to-make-mountain-array/
//
// Time Complexity: O(N log N), where N is the number of elements in the array. We calculate 
// the Longest Increasing Subsequence (LIS) from left to right and right to left. 
// Using binary search, LIS takes O(N log N) time.
// Space Complexity: O(N) to store the LIS and LDS lengths for each index, and the dpList for binary search.

class Solution {
    func minimumMountainRemovals(_ nums: [Int]) -> Int {
        let n = nums.count
        
        // lis[i] stores the length of Longest Increasing Subsequence ending at index i
        var lis = Array(repeating: 1, count: n)
        var dpList = [Int]() // Helper array for O(N log N) LIS using binary search
        
        // Compute LIS from left to right
        for i in 0..<n {
            let num = nums[i]
            var left = 0
            var right = dpList.count
            
            // Binary search to find the correct position to insert/replace
            while left < right {
                let mid = left + (right - left) / 2
                if dpList[mid] < num {
                    left = mid + 1
                } else {
                    right = mid
                }
            }
            
            if left == dpList.count {
                dpList.append(num)
            } else {
                dpList[left] = num
            }
            lis[i] = left + 1
        }
        
        // lds[i] stores the length of Longest Decreasing Subsequence starting at index i
        // (which is equivalent to LIS from right to left)
        var lds = Array(repeating: 1, count: n)
        dpList.removeAll() // Clear for reuse
        
        // Compute LIS from right to left
        for i in stride(from: n - 1, through: 0, by: -1) {
            let num = nums[i]
            var left = 0
            var right = dpList.count
            
            while left < right {
                let mid = left + (right - left) / 2
                if dpList[mid] < num {
                    left = mid + 1
                } else {
                    right = mid
                }
            }
            
            if left == dpList.count {
                dpList.append(num)
            } else {
                dpList[left] = num
            }
            lds[i] = left + 1
        }
        
        var maxMountainLength = 0
        
        // Find the maximum mountain length
        // A valid mountain must have elements on both increasing and decreasing sides (length > 1)
        for i in 1..<(n - 1) {
            if lis[i] > 1 && lds[i] > 1 {
                maxMountainLength = max(maxMountainLength, lis[i] + lds[i] - 1)
            }
        }
        
        // The minimum removals is the total length minus the maximum mountain length
        return n - maxMountainLength
    }
}
