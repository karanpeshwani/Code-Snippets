// 761. Special Binary String
// https://leetcode.com/problems/special-binary-string

/*
 Intuition:
 A special binary string can be mapped to valid parentheses. '1' is '(' and '0' is ')'.
 Every special string can be split into smaller, independent, non-empty special binary strings.
 For example, a valid string might be made up of `A + B + C` where A, B, C are special.
 Our goal is to make the string lexicographically largest. To do this, we should find the
 independent special sub-strings, recursively make them as large as possible, sort them in
 descending order, and concatenate them.
 How to find an irreducible special string? It starts with '1' and ends with '0'. We can
 strip the outer '1' and '0', recursively solve the inner part, and put them back.

 Time Complexity: O(N^2)
 - Finding the valid splits takes O(N).
 - The string operations and sorting take additional time. In the worst case (deeply nested
   or many small siblings), it resembles O(N^2) due to string slicing and concatenation.
 
 Space Complexity: O(N)
 - The recursion stack can go up to depth N.
 - The array of substrings and intermediate strings take up to O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    func makeLargestSpecial(_ s: String) -> String {
        var count = 0
        var i = 0
        let chars = Array(s)
        var substrings = [String]()
        
        for j in 0..<chars.count {
            if chars[j] == "1" {
                count += 1
            } else {
                count -= 1
            }
            
            // When count reaches 0, we've found a complete special substring
            if count == 0 {
                // Remove outer '1' and '0' and recursively make the inside largest
                // The inside is chars[i+1...j-1]
                let inner = String(chars[(i + 1)..<j])
                let largestInner = makeLargestSpecial(inner)
                
                // Add back the outer '1' and '0'
                substrings.append("1" + largestInner + "0")
                
                i = j + 1
            }
        }
        
        // Sort substrings in lexicographically descending order
        substrings.sort(by: >)
        
        return substrings.joined()
    }
}
