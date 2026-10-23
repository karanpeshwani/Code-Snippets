// 41. First Missing Positive
// https://leetcode.com/problems/first-missing-positive

/*
 Intuition/Explanation:
 We can use a cyclic sort approach. The goal is to place each positive number `x` in the range `[1, n]` 
 at its correct index `x - 1` (e.g., number 1 goes to index 0, number 2 to index 1).
 We iterate through the array, and while `nums[i]` is a valid positive number less than or equal to `n`, 
 and it is not already at its correct index (`nums[nums[i] - 1] != nums[i]`), we swap them.
 After this sorting process, we scan the array again. The first index `i` where `nums[i] != i + 1` 
 means `i + 1` is the smallest missing positive integer.
 If all numbers from `1` to `n` are present, the missing positive is `n + 1`.

 Time Complexity: O(N), where N is the length of the array. Each number is swapped to its correct position at most once.
 Space Complexity: O(1), as we modify the array in-place.
*/

class Solution {
    func firstMissingPositive(_ nums: [Int]) -> Int {
        var nums = nums
        let n = nums.count
        
        // Cyclic sort to place numbers in their correct indices
        for i in 0..<n {
            // While nums[i] is in range [1, n] and not at the correct position
            while nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] != nums[i] {
                // Swap nums[i] with the element at its correct index nums[i] - 1
                let correctIndex = nums[i] - 1
                nums.swapAt(i, correctIndex)
            }
        }
        
        // Find the first missing positive
        for i in 0..<n {
            if nums[i] != i + 1 {
                return i + 1
            }
        }
        
        // If all 1 to n are present, the answer is n + 1
        return n + 1
    }
}
