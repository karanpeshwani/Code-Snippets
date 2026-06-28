//Again
// 4. Median of Two Sorted Arrays
// https://leetcode.com/problems/median-of-two-sorted-arrays
//
// Time Complexity: O(log(min(M, N)))
// Space Complexity: O(1)
//
// Explanation:
// To achieve the required O(log(M+N)) or better time complexity, we can use binary search on the smaller array.
// Let the arrays be A (size M) and B (size N). We assume M <= N (if not, we swap them).
// We partition A and B such that the left half contains half of the total elements (or half + 1 if total is odd).
// We binary search for the correct partition index in A. For a chosen partition in A, the partition in B is determined.
// We then check if the elements around the partitions satisfy the condition: max(leftA) <= min(rightB) and max(leftB) <= min(rightA).
// If satisfied, we found the correct partition, and we can calculate the median.
// The binary search space is the smaller array, so time complexity is O(log(min(M, N))). Space is O(1).

class Solution {
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        let a = nums1.count <= nums2.count ? nums1 : nums2
        let b = nums1.count <= nums2.count ? nums2 : nums1
        let m = a.count
        let n = b.count
        
        var left = 0
        var right = m
        let halfLen = (m + n + 1) / 2
        
        while left <= right {
            let i = left + (right - left) / 2
            let j = halfLen - i
            
            let aLeftMax = i == 0 ? Int.min : a[i - 1]
            let aRightMin = i == m ? Int.max : a[i]
            let bLeftMax = j == 0 ? Int.min : b[j - 1]
            let bRightMin = j == n ? Int.max : b[j]
            
            if aLeftMax <= bRightMin && bLeftMax <= aRightMin {
                // Correct partition found
                if (m + n) % 2 == 1 {
                    return Double(max(aLeftMax, bLeftMax))
                } else {
                    return Double(max(aLeftMax, bLeftMax) + min(aRightMin, bRightMin)) / 2.0
                }
            } else if aLeftMax > bRightMin {
                // Partition in A is too far right
                right = i - 1
            } else {
                // Partition in A is too far left
                left = i + 1
            }
        }
        
        fatalError("Input arrays are not sorted or invalid")
    }
}
