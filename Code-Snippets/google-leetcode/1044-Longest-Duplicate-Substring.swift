// 1044. Longest Duplicate Substring
// Link: https://leetcode.com/problems/longest-duplicate-substring/
//
// Time Complexity: O(N log N), where N is the length of the string.
// Explanation: We use Binary Search for the length of the duplicate substring (O(log N)). For each length, we use the Rabin-Karp algorithm (Rolling Hash) which takes O(N) time to find a match.
// Space Complexity: O(N)
// Explanation: We store the hash set to check for duplicates, which in the worst case can store N substrings. The string is also converted to an array of integers for O(1) access.

class Solution {
    func longestDupSubstring(_ s: String) -> String {
        // Map 'a'-'z' to 0-25 for easier hashing
        let chars = Array(s.utf8).map { Int($0 - 97) } 
        let n = chars.count
        let base = 26
        let modulus = 1_000_000_007
        
        // Search for a duplicate substring of length 'L' using Rabin-Karp
        func search(_ L: Int) -> Int? {
            var hash = 0
            var power = 1
            
            // Precompute hash for the first window and the power `base^L % modulus`
            for i in 0..<L {
                hash = (hash * base + chars[i]) % modulus
                if i < L - 1 {
                    power = (power * base) % modulus
                }
            }
            
            // Map hash to starting indices to handle collisions
            var seen = [Int: [Int]]()
            seen[hash] = [0]
            
            for i in 1...(n - L) {
                // Rolling hash update: remove outgoing character and add incoming character
                hash = (hash - (chars[i - 1] * power) % modulus + modulus) % modulus
                hash = (hash * base + chars[i + L - 1]) % modulus
                
                if let indices = seen[hash] {
                    // Check for actual equality to resolve hash collisions
                    for startIndex in indices {
                        var match = true
                        for j in 0..<L {
                            if chars[startIndex + j] != chars[i + j] {
                                match = false
                                break
                            }
                        }
                        if match {
                            return i
                        }
                    }
                }
                
                seen[hash, default: []].append(i)
            }
            
            return nil
        }
        
        var left = 1
        var right = n
        var bestStart = -1
        var bestLength = 0
        
        // Binary search on the possible lengths of the duplicate substring
        while left <= right {
            let mid = left + (right - left) / 2
            
            if let start = search(mid) {
                // If a duplicate of length 'mid' is found, try longer lengths
                bestStart = start
                bestLength = mid
                left = mid + 1
            } else {
                // Otherwise, try shorter lengths
                right = mid - 1
            }
        }
        
        if bestLength == 0 { return "" }
        
        // Safely extract the substring using String indices
        let startIndex = s.index(s.startIndex, offsetBy: bestStart)
        let endIndex = s.index(startIndex, offsetBy: bestLength)
        return String(s[startIndex..<endIndex])
    }
}
