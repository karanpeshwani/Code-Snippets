// 1371. Find the Longest Substring Containing Vowels in Even Counts
// https://leetcode.com/problems/find-the-longest-substring-containing-vowels-in-even-counts/

/*
 Intuition:
 We need to find the longest substring where every vowel ('a', 'e', 'i', 'o', 'u') appears an even number of times.
 Since we only care about whether the count is even or odd, we can represent the parity of the counts 
 using a 5-bit integer (bitmask). 0 means even count, 1 means odd count.
 As we iterate through the string, we update this bitmask. For example, if we see an 'a', we flip the 0th bit.
 The key insight is: if we encounter the same bitmask at index `i` and index `j` (`i < j`), 
 the substring between `i+1` and `j` must have an even number of all vowels. 
 This is because the parity of vowel counts returned to what it was at index `i`.
 We can use a hash map (or an array of size 32) to store the first time we see each bitmask.

 Time Complexity: O(N)
 - N is the length of the string `s`.
 - We iterate through the string exactly once, performing O(1) operations per character.
 - Total time complexity is O(N).

 Space Complexity: O(1)
 - We use an array of size 32 to store the first occurrence index of each bitmask.
 - Since the array size is constant, the space complexity is O(1).
 */

class Solution {
    func findTheLongestSubstring(_ s: String) -> Int {
        // Map vowels to their respective bit index
        let vowels: [Character: Int] = ["a": 0, "e": 1, "i": 2, "o": 3, "u": 4]
        
        // Array to store the first occurrence of each state (bitmask)
        // Initialized with -2 to indicate "not seen yet"
        var firstOccurrence = Array(repeating: -2, count: 32)
        
        // State 0 (all vowels even) is seen at index -1
        firstOccurrence[0] = -1
        
        var currentMask = 0
        var maxLength = 0
        
        for (i, char) in s.enumerated() {
            if let bitIndex = vowels[char] {
                // Flip the bit corresponding to the vowel
                currentMask ^= (1 << bitIndex)
            }
            
            if firstOccurrence[currentMask] != -2 {
                // If we have seen this mask before, we found a valid substring
                maxLength = max(maxLength, i - firstOccurrence[currentMask])
            } else {
                // Store the first time we see this mask
                firstOccurrence[currentMask] = i
            }
        }
        
        return maxLength
    }
}
