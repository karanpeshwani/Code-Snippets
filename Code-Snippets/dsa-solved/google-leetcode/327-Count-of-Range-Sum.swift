//Again -> Segment Tree
// 327. Count of Range Sum
// https://leetcode.com/problems/count-of-range-sum/

/*
 Intuition:
 We need to find the number of subarrays with a sum in the range [lower, upper].
 A naive O(N^2) approach checks all subarrays, but we can optimize this.
 Using prefix sums, the sum of a subarray from index `i` to `j` is `prefix[j + 1] - prefix[i]`.
 The condition `lower <= prefix[j + 1] - prefix[i] <= upper` can be rewritten as:
 `prefix[j + 1] - upper <= prefix[i] <= prefix[j + 1] - lower` (where i < j + 1).

 We can use a modified Merge Sort on the prefix sums array to count these pairs efficiently.
 During the merge step, both the left half and right half are already sorted.
 For each element `rightElement` in the right half, we want to find how many elements `leftElement`
 in the left half satisfy `rightElement - upper <= leftElement <= rightElement - lower`.
 Because the left half is sorted and we iterate through the right half in ascending order,
 the bounds `rightElement - upper` and `rightElement - lower` also increase monotonically.
 Thus, we can maintain two pointers (`p1` and `p2`) in the left half that only move forward,
 giving us an O(N) counting step inside the merge function.

 Time Complexity: O(N log N)
 - Calculating the prefix sum array takes O(N).
 - The merge sort divides the array log N times.
 - The counting and merging steps take O(N) at each level of recursion.
 - Overall time complexity is O(N log N).

 Space Complexity: O(N)
 - We create a prefix sum array of size N + 1.
 - The merge sort uses a temporary array of size up to N + 1 for merging.
 - The recursion stack depth is O(log N).
 - Overall space complexity is O(N).
 */

class Solution {
    func countRangeSum(_ nums: [Int], _ lower: Int, _ upper: Int) -> Int {
        var prefixSums = [Int](repeating: 0, count: nums.count + 1)
        for i in 0..<nums.count {
            prefixSums[i + 1] = prefixSums[i] + nums[i]
        }

        return mergeSortAndCount(&prefixSums, 0, prefixSums.count - 1, lower, upper)
    }

    private func mergeSortAndCount(_ arr: inout [Int], _ left: Int, _ right: Int, _ lower: Int, _ upper: Int) -> Int {
        if left >= right {
            return 0
        }

        let mid = left + (right - left) / 2
        var count = mergeSortAndCount(&arr, left, mid, lower, upper) + mergeSortAndCount(&arr, mid + 1, right, lower, upper)

        // Count valid pairs across the two halves
        var p1 = left
        var p2 = left

        for j in (mid + 1)...right {
            // Find the first index p1 such that arr[p1] >= arr[j] - upper
            while p1 <= mid && arr[p1] < arr[j] - upper {
                p1 += 1
            }

            // Find the first index p2 such that arr[p2] > arr[j] - lower
            while p2 <= mid && arr[p2] <= arr[j] - lower {
                p2 += 1
            }

            count += (p2 - p1)
        }

        // Merge the two sorted halves
        var temp = [Int]()
        var l = left
        var r = mid + 1

        while l <= mid && r <= right {
            if arr[l] <= arr[r] {
                temp.append(arr[l])
                l += 1
            } else {
                temp.append(arr[r])
                r += 1
            }
        }

        while l <= mid {
            temp.append(arr[l])
            l += 1
        }

        while r <= right {
            temp.append(arr[r])
            r += 1
        }

        for i in 0..<temp.count {
            arr[left + i] = temp[i]
        }

        return count
    }
}

