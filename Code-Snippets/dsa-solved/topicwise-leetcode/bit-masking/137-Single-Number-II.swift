// 137. Single Number II
// https://leetcode.com/problems/single-number-ii/

/*
 Intuition:
 Every number appears three times except for one number. If we sum the bits at each position
 across all numbers, the sum at each position will be a multiple of 3 if the single number's
 bit at that position is 0. If it's 1, the sum will be of the form 3k + 1. 
 A more optimal approach using bitwise operations tracks the bits that appear once (`ones`) 
 and twice (`twos`). When a bit appears a third time, we clear it from both `ones` and `twos`.
 We can update `ones` as `(ones ^ num) & ~twos` and `twos` as `(twos ^ num) & ~ones`.

 Time Complexity: O(N)
 - We iterate through the given array of size N exactly once.
 - Each operation inside the loop takes O(1) time.
 - Total time complexity is O(N).

 Space Complexity: O(1)
 - We only use two integer variables (`ones` and `twos`) to keep track of bits.
 - Overall space complexity is O(1).
 */

class Solution {
    func singleNumber(_ nums: [Int]) -> Int {
        var ones = 0
        var twos = 0
        
        for num in nums {
            // Update ones: add num to ones if it's not in twos
            ones = (ones ^ num) & ~twos
            // Update twos: add num to twos if it's not in ones
            twos = (twos ^ num) & ~ones
        }
        
        return ones
    }
}
