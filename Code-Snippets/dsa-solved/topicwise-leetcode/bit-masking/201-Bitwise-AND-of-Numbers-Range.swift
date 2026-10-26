// 201. Bitwise AND of Numbers Range
// https://leetcode.com/problems/bitwise-and-of-numbers-range/

/*
 Intuition:
 The bitwise AND of all numbers in the range [left, right] is essentially the common prefix of their binary representations. 
 Any bit to the right of the common prefix will flip at least once (from 0 to 1 and back) between `left` and `right`. 
 Because anything ANDed with 0 is 0, all bits to the right of the common prefix will become 0 in the final answer. 
 We can find this common prefix by continuously right-shifting both `left` and `right` until they are equal, 
 while keeping track of the number of shifts. Finally, we left-shift the common prefix by the recorded shift count.

 Time Complexity: O(1)
 - The number of shifts is at most the number of bits in an integer (32 or 64 bits), which is a constant.
 - Thus, the time complexity is O(1) (or O(log N) where N is the maximum value, but bounded by 32/64).

 Space Complexity: O(1)
 - We only use a single integer variable `shifts` to keep track of the shift count.
 - Overall space complexity is O(1).
 */

class Solution {
    func rangeBitwiseAnd(_ left: Int, _ right: Int) -> Int {
        var m = left
        var n = right
        var shifts = 0
        
        // Find the common prefix of left and right
        while m < n {
            m >>= 1
            n >>= 1
            shifts += 1
        }
        
        // Shift the common prefix back to its original position
        return m << shifts
    }
}
