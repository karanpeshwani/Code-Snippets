// 318. Maximum Product of Word Lengths
// https://leetcode.com/problems/maximum-product-of-word-lengths/

/*
 Intuition:
 We need to find two words that do not share any common letters and have the maximum product of their lengths.
 Since the words only contain lowercase English letters, we can represent the characters present in a word
 using a 26-bit integer (bitmask). The i-th bit is 1 if the i-th letter ('a' + i) is present in the word.
 Two words share no common letters if the bitwise AND of their bitmasks is 0 (`mask1 & mask2 == 0`).
 We can precompute the bitmask for each word. To optimize, if multiple words produce the same bitmask, 
 we only need to keep the maximum length among them. Then, we compare all pairs of distinct bitmasks.

 Time Complexity: O(L + N^2)
 - L is the total length of all words combined. We iterate over all characters to compute the masks in O(L) time.
 - N is the number of unique masks (at most the number of words). We compare all pairs of unique masks, taking O(N^2) time.
 - Total time complexity is O(L + N^2).

 Space Complexity: O(N)
 - We use a dictionary (hash map) to store the maximum length for each unique bitmask.
 - At most, there will be N entries in the dictionary.
 - Overall space complexity is O(N).
 */

class Solution {
    func maxProduct(_ words: [String]) -> Int {
        var maskToMaxLength = [Int: Int]()
        
        // Compute bitmask for each word and store the maximum length for each mask
        for word in words {
            var mask = 0
            for char in word {
                let bitIndex = Int(char.asciiValue! - Character("a").asciiValue!)
                mask |= (1 << bitIndex)
            }
            maskToMaxLength[mask] = max(maskToMaxLength[mask, default: 0], word.count)
        }
        
        var maxProduct = 0
        let uniqueMasks = Array(maskToMaxLength.keys)
        let n = uniqueMasks.count
        
        // Compare all pairs of unique masks
        for i in 0..<n {
            for j in (i + 1)...<n {
                let mask1 = uniqueMasks[i]
                let mask2 = uniqueMasks[j]
                
                // If they don't share common letters
                if (mask1 & mask2) == 0 {
                    let product = maskToMaxLength[mask1]! * maskToMaxLength[mask2]!
                    maxProduct = max(maxProduct, product)
                }
            }
        }
        
        return maxProduct
    }
}
