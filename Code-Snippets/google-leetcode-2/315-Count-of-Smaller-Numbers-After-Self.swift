// 315. Count of Smaller Numbers After Self
// https://leetcode.com/problems/count-of-smaller-numbers-after-self
//
// Intuition/Explanation:
// We can use a modified Merge Sort to solve this efficiently in O(N log N).
// We sort an array of `(value, original_index)` tuples so we know which index to update in our result array.
// During the merge step of Merge Sort (merging sorted left and right halves):
// When we pick an element from the left half to place in the merged array, it means this element is 
// strictly smaller than or equal to the remaining elements in the right half.
// Crucially, all the elements we have ALREADY placed from the right half are STRICTLY SMALLER than 
// the current element we are placing from the left half.
// So, we just add the count of already-placed right elements to the answer for the current left element's original index.
//
// Time Complexity: O(N log N), which is standard for merge sort algorithms.
// Space Complexity: O(N) for the temporary array during merge sort and the tuple array.

class Solution {
    func countSmaller(_ nums: [Int]) -> [Int] {
        let n = nums.count
        if n == 0 { return [] }
        
        var result = Array(repeating: 0, count: n)
        // Store (value, original_index)
        var indexedNums = [(val: Int, idx: Int)]()
        for (index, value) in nums.enumerated() {
            indexedNums.append((val: value, idx: index))
        }
        
        func mergeSort(_ arr: inout [(val: Int, idx: Int)], _ left: Int, _ right: Int) {
            if left >= right { return }
            
            let mid = left + (right - left) / 2
            mergeSort(&arr, left, mid)
            mergeSort(&arr, mid + 1, right)
            
            merge(&arr, left, mid, right)
        }
        
        func merge(_ arr: inout [(val: Int, idx: Int)], _ left: Int, _ mid: Int, _ right: Int) {
            var temp = [(val: Int, idx: Int)]()
            var i = left
            var j = mid + 1
            var rightCount = 0 // Count of elements taken from the right half
            
            while i <= mid && j <= right {
                if arr[i].val <= arr[j].val {
                    // Element from left is smaller or equal
                    result[arr[i].idx] += rightCount
                    temp.append(arr[i])
                    i += 1
                } else {
                    // Element from right is strictly smaller
                    rightCount += 1
                    temp.append(arr[j])
                    j += 1
                }
            }
            
            while i <= mid {
                result[arr[i].idx] += rightCount
                temp.append(arr[i])
                i += 1
            }
            
            while j <= right {
                temp.append(arr[j])
                j += 1
            }
            
            // Copy back to original array
            for k in 0..<temp.count {
                arr[left + k] = temp[k]
            }
        }
        
        mergeSort(&indexedNums, 0, n - 1)
        return result
    }
}
