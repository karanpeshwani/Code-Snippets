// 493. Reverse Pairs
// https://leetcode.com/problems/reverse-pairs

/*
 Intuition:
 We need to count pairs (i, j) such that i < j and nums[i] > 2 * nums[j].
 This is a variation of the classic "count inversions" problem, which can be solved efficiently
 using Merge Sort.
 During the merge step of Merge Sort, both the left half and right half are already sorted.
 For each element in the left half, we can find how many elements in the right half satisfy
 the condition `nums[i] > 2 * nums[j]`. Because both halves are sorted, we can use a two-pointer
 approach to count these pairs in O(N) time for the merge step.
 Then, we proceed to merge the two halves as usual.

 Time Complexity: O(N log N)
 - The merge sort divides the array log N times.
 - In each level of recursion, the counting step and the merging step both take linear time O(N)
   in proportion to the subarray size.
 - Overall time complexity is O(N log N).

 Space Complexity: O(N)
 - Merge sort requires a temporary array of the same size as the input to merge the halves.
 - The recursion stack goes up to O(log N) depth.
 - Overall space complexity is O(N).
 */

class Solution {
    func reversePairs(_ nums: [Int]) -> Int {
        var nums = nums
        return mergeSort(&nums, 0, nums.count - 1)
    }
    
    private func mergeSort(_ nums: inout [Int], _ left: Int, _ right: Int) -> Int {
        if left >= right { return 0 }
        
        let mid = left + (right - left) / 2
        
        var count = mergeSort(&nums, left, mid) + mergeSort(&nums, mid + 1, right)
        
        // Count reverse pairs
        var j = mid + 1
        for i in left...mid {
            while j <= right && Double(nums[i]) / 2.0 > Double(nums[j]) {
                j += 1
            }
            count += j - (mid + 1)
        }
        
        // Merge the two halves
        var temp = [Int]()
        var l = left
        var r = mid + 1
        
        while l <= mid && r <= right {
            if nums[l] <= nums[r] {
                temp.append(nums[l])
                l += 1
            } else {
                temp.append(nums[r])
                r += 1
            }
        }
        
        while l <= mid {
            temp.append(nums[l])
            l += 1
        }
        
        while r <= right {
            temp.append(nums[r])
            r += 1
        }
        
        for i in 0..<temp.count {
            nums[left + i] = temp[i]
        }
        
        return count
    }
}
