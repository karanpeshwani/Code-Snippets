// 30. Substring with Concatenation of All Words
// https://leetcode.com/problems/substring-with-concatenation-of-all-words

/*
 Intuition/Explanation:
 Since all words in the `words` array have the exact same length (`wordLen`), we can use a sliding window approach.
 We can group our searches by the starting index modulo `wordLen`. There will be `wordLen` such groups.
 For each group (offset), we slide a window by steps of `wordLen`.
 We maintain a map of the currently seen words in the window. If the window matches the required word counts, 
 we record the starting index. When we slide the window, we add the new word on the right and remove the word on the left.

 Time Complexity: O(N * L), where N is the length of the string `s` and L is the length of each word.
 We traverse the string `L` times (for each offset). Each traversal processes elements in steps of `L`, taking O(N/L) steps.
 Substring extraction and map operations take O(L). Total: O(L * (N/L) * L) = O(N * L).
 Space Complexity: O(W * L), where W is the number of words. The space is used for storing the word counts 
 in dictionaries, and each word has length L.
*/

class Solution {
    func findSubstring(_ s: String, _ words: [String]) -> [Int] {
        guard !words.isEmpty else { return [] }
        
        let wordLen = words[0].count
        let totalWords = words.count
        let sLen = s.count
        
        if sLen < wordLen * totalWords { return [] }
        
        // Count frequencies of each word
        var wordCount = [String: Int]()
        for word in words {
            wordCount[word, default: 0] += 1
        }
        
        var result = [Int]()
        let sChars = Array(s) // Use array of characters for O(1) index access
        
        // We only need to start from 0 to wordLen - 1
        for i in 0..<wordLen {
            var left = i
            var right = i
            var currentCount = [String: Int]()
            var matchedWords = 0
            
            while right + wordLen <= sLen {
                // Extract the word at the right end of the window
                let wordStr = String(sChars[right..<right+wordLen])
                right += wordLen
                
                if let count = wordCount[wordStr] {
                    currentCount[wordStr, default: 0] += 1
                    matchedWords += 1
                    
                    // If we have more of `wordStr` than needed, shrink the window from the left
                    while currentCount[wordStr]! > count {
                        let leftWord = String(sChars[left..<left+wordLen])
                        currentCount[leftWord]! -= 1
                        matchedWords -= 1
                        left += wordLen
                    }
                    
                    // If we found a valid concatenation, add the start index to result
                    if matchedWords == totalWords {
                        result.append(left)
                    }
                } else {
                    // Invalid word found, reset the window
                    currentCount.removeAll()
                    matchedWords = 0
                    left = right
                }
            }
        }
        
        return result
    }
}
