// 421. Maximum XOR of Two Numbers in an Array
// https://leetcode.com/problems/maximum-xor-of-two-numbers-in-an-array/

/*
 Intuition:
 We want to find the maximum possible XOR of any two numbers in the array.
 We can build this maximum value bit by bit, starting from the most significant bit (31) down to 0.
 At each bit position `i`, we guess that we can set this bit to 1 in our maximum XOR value.
 Let's say our guessed max so far is `expectedMax = currentMax | (1 << i)`.
 We can check if `expectedMax` is achievable by looking at the prefixes of all numbers up to the i-th bit.
 For two prefixes `A` and `B`, if `A ^ B = expectedMax`, then `A ^ expectedMax = B`.
 We can store all prefixes in a Hash Set. Then, for each prefix, we check if `prefix ^ expectedMax` 
 exists in the set. If it does, our guess was correct, and we update `currentMax = expectedMax`.
 Otherwise, the i-th bit of the maximum XOR must be 0.

 Time Complexity: O(N)
 - We iterate 32 times (constant for 32-bit integers).
 - Inside the loop, we iterate through the N numbers to extract prefixes and insert them into a Set, taking O(N) time.
 - Then we iterate through the N prefixes to check for matches, taking O(N) time.
 - Total time complexity is O(32 * N) = O(N).

 Space Complexity: O(N)
 - At each bit position, we store up to N prefixes in a Hash Set.
 - Overall space complexity is O(N).
 */

class Solution {
    func findMaximumXOR(_ nums: [Int]) -> Int {
        var maxXor = 0
        var mask = 0
        
        for i in stride(from: 31, through: 0, by: -1) {
            // Expand the mask to include the current bit
            mask = mask | (1 << i)
            
            var prefixes = Set<Int>()
            for num in nums {
                prefixes.insert(num & mask)
            }
            
            // Guess that the i-th bit can be set to 1
            let expectedMax = maxXor | (1 << i)
            
            // Check if there are two prefixes A and B such that A ^ expectedMax = B
            for prefix in prefixes {
                if prefixes.contains(prefix ^ expectedMax) {
                    maxXor = expectedMax
                    break
                }
            }
        }
        
        return maxXor
    }
}
