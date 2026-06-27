// 127. Word Ladder
// https://leetcode.com/problems/word-ladder/
//
// Time Complexity: O(M^2 * N), where M is the length of each word and N is the total number of words in the wordList. In the worst case, for each word we change every character (M times) to 26 different letters and create a new string (takes O(M)), giving O(M^2) per word. Bidirectional BFS significantly reduces the branching factor in practice, but asymptotic upper bound remains the same.
// Space Complexity: O(M * N), since we store sets of strings for our forward and backward BFS frontiers, as well as a word set for fast lookups. Storing N strings of length M requires O(M * N) space.

class Solution {
    func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
        var wordSet = Set(wordList)
        
        // If endWord is not in the dictionary, no valid transformation sequence exists
        if !wordSet.contains(endWord) {
            return 0
        }
        
        // We use bidirectional BFS to minimize the search space
        var forwardSet: Set<String> = [beginWord]
        var backwardSet: Set<String> = [endWord]
        
        // Remove begin and end words from the dictionary to avoid cycles
        wordSet.remove(beginWord)
        wordSet.remove(endWord)
        
        var step = 1
        let aAscii = Character("a").asciiValue!
        
        while !forwardSet.isEmpty && !backwardSet.isEmpty {
            // Always expand the smaller set to minimize branching factor and optimize speed
            if forwardSet.count > backwardSet.count {
                swap(&forwardSet, &backwardSet)
            }
            
            var nextSet: Set<String> = []
            
            // Expand all words in the current level of the smaller set
            for word in forwardSet {
                var chars = Array(word)
                
                // Try substituting every character of the word with 'a' to 'z'
                for i in 0..<chars.count {
                    let originalChar = chars[i]
                    
                    for j in 0..<26 {
                        let newChar = Character(UnicodeScalar(aAscii + UInt8(j)))
                        if newChar == originalChar { continue }
                        
                        chars[i] = newChar
                        let nextWord = String(chars)
                        
                        // If the next word is in the other side's set, the two searches have met
                        // The total path length is the number of steps taken so far + 1
                        if backwardSet.contains(nextWord) {
                            return step + 1
                        }
                        
                        // If it's a valid unvisited dictionary word, add it to the next level's frontier
                        if wordSet.contains(nextWord) {
                            nextSet.insert(nextWord)
                            wordSet.remove(nextWord)
                        }
                    }
                    
                    // Backtrack the character change before moving to the next position
                    chars[i] = originalChar
                }
            }
            
            // Move forward to the next level
            forwardSet = nextSet
            step += 1
        }
        
        return 0
    }
}
