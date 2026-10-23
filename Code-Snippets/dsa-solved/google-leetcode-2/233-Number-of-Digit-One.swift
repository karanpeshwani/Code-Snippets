// 233. Number of Digit One
// https://leetcode.com/problems/number-of-digit-one

/*
 Intuition/Explanation:
 We can count the number of 1s at each digit position (ones, tens, hundreds, etc.) individually.
 For a given position `i` (where i is 1, 10, 100, ...), we split `n` into two parts: 
 higher digits (n / (i * 10)) and lower digits (n % i).
 The current digit at position `i` is `(n / i) % 10`.
 - If the current digit is 0: The number of 1s at this position is determined purely by the higher digits.
 - If the current digit is 1: The number of 1s is determined by the higher digits PLUS the lower digits + 1.
 - If the current digit is > 1: The number of 1s is determined by the higher digits + 1.
 We sum these counts for all digit positions.

 Time Complexity: O(log_10(N)), since we iterate through each digit of the number `n`.
 Space Complexity: O(1), as we only use a few variables for counting.
*/

class Solution {
    func countDigitOne(_ n: Int) -> Int {
        if n <= 0 { return 0 }
        
        var count = 0
        var i = 1
        
        while i <= n {
            let higher = n / (i * 10)
            let lower = n % i
            let currentDigit = (n / i) % 10
            
            if currentDigit == 0 {
                count += higher * i
            } else if currentDigit == 1 {
                count += higher * i + lower + 1
            } else {
                count += (higher + 1) * i
            }
            
            i *= 10
        }
        
        return count
    }
}
