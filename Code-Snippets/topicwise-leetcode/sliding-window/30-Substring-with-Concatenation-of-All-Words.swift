// 30. Substring with Concatenation of All Words
// https://leetcode.com/problems/substring-with-concatenation-of-all-words/

/*
 Intuition:
 We need to find all starting indices in `s` where a substring is a concatenation of all words in `words`.
 All words have the same length, say `wordLen`.
 The total length of the concatenated string will be `totalLen = words.count * wordLen`.
 Since words have a fixed length, we can divide the string `s` into `wordLen` different groups based on the starting index modulo `wordLen`.
 For each group, we can use a sliding window of size `totalLen` to check if the words in the window match the required words.
 We maintain a frequency dictionary of the words in `words`. As the window slides, we add the word entering the window
 and remove the word leaving the window from our current window frequency count.
 We also keep track of how many valid words are currently in our window to easily check for a match.

 Time Complexity: O(N * L) or O(N) depending on implementation details
 - N is the length of string `s` and L is the length of each word.
 - We process `s` in `wordLen` shifts. In each shift, we process `N / wordLen` words.
 - Total words processed is bounded by `N`.
 - String slicing and hashing takes O(L) per word.
 - Overall time complexity is O(N * L).

 Space Complexity: O(M * L)
 - M is the number of words in `words` and L is the word length.
 - The frequency dictionary stores at most M words.
 - Slices of the string also require some space.
 - Overall space complexity is O(M * L).
 */

class Solution {
    func findSubstring(_ s: String, _ words: [String]) -> [Int] {
        guard !s.isEmpty, !words.isEmpty else { return [] }
        
        let wordLen = words[0].count
        let wordCount = words.count
        let totalLen = wordLen * wordCount
        let n = s.count
        
        guard n >= totalLen else { return [] }
        
        var wordFreq = [String: Int]()
        for word in words {
            wordFreq[word, default: 0] += 1
        }
        
        var result = [Int]()
        let sArray = Array(s)
        
        for i in 0..<wordLen {
            var left = i
            var right = i
            var currentFreq = [String: Int]()
            var matchCount = 0
            
            while right + wordLen <= n {
                let rightWord = String(sArray[right..<right+wordLen])
                right += wordLen
                
                if let targetFreq = wordFreq[rightWord] {
                    currentFreq[rightWord, default: 0] += 1
                    if currentFreq[rightWord]! <= targetFreq {
                        matchCount += 1
                    } else {
                        // Word is seen more times than needed, shrink from left
                        while currentFreq[rightWord]! > targetFreq {
                            let leftWord = String(sArray[left..<left+wordLen])
                            currentFreq[leftWord]! -= 1
                            if currentFreq[leftWord]! < wordFreq[leftWord]! {
                                matchCount -= 1
                            }
                            left += wordLen
                        }
                    }
                    
                    if matchCount == wordCount {
                        result.append(left)
                        // Advance left by one word to find next potential match
                        let leftWord = String(sArray[left..<left+wordLen])
                        currentFreq[leftWord]! -= 1
                        matchCount -= 1
                        left += wordLen
                    }
                } else {
                    // Invalid word, reset window
                    currentFreq.removeAll()
                    matchCount = 0
                    left = right
                }
            }
        }
        
        return result
    }
}
