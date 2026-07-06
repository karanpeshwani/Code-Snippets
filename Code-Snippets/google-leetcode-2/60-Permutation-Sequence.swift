// 60. Permutation Sequence
// https://leetcode.com/problems/permutation-sequence
//
// Intuition/Explanation:
// Instead of generating all permutations (which takes O(N!) time), we can determine the k-th permutation mathematically.
// For `n` numbers, there are `(n - 1)!` permutations starting with each of the `n` digits.
// We can find the first digit by calculating `(k - 1) / (n - 1)!`. This gives the index in the sorted list of available digits.
// After picking the digit, we update `k = (k - 1) % (n - 1)!` and repeat the process for the next digit using `(n - 2)!`.
// We maintain an array of available digits `[1, 2, ..., n]` and remove digits as they are picked to form the result.
//
// Time Complexity: O(N^2), where N is the number of digits. We iterate N times, and removing an element 
// from the middle of an array takes O(N) time.
// Space Complexity: O(N) to store the list of available digits and precomputed factorials.

class Solution {
    func getPermutation(_ n: Int, _ k: Int) -> String {
        var factorials = Array(repeating: 1, count: n + 1)
        var numbers = [Int]()
        
        // Precompute factorials and initialize numbers array
        for i in 1...n {
            factorials[i] = factorials[i - 1] * i
            numbers.append(i)
        }
        
        // k is 1-indexed, make it 0-indexed for easier math
        var k = k - 1
        var result = ""
        
        for i in (1...n).reversed() {
            // Find the index of the digit to pick
            let index = k / factorials[i - 1]
            
            // Append the digit and remove it from available numbers
            result += String(numbers[index])
            numbers.remove(at: index)
            
            // Update k for the remaining digits
            k = k % factorials[i - 1]
        }
        
        return result
    }
}
