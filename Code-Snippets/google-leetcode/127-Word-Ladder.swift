// 127. Word Ladder
// https://leetcode.com/problems/word-ladder/
//
// Time Complexity: O(M^2 * N), where M is the length of each word and N is the total number of words in the wordList.
// For each word, we change every character (M times) to 26 different letters and create a new string (takes O(M)), giving O(M^2) per word.
// Space Complexity: O(M * N), since we store strings for our BFS queue and word set. Storing N strings of length M requires O(M * N) space.

class Solution {
    func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
        var wordSet = Set(wordList)

        // If endWord is not in the dictionary, no valid transformation sequence exists
        if !wordSet.contains(endWord) {
            return 0
        }

        // Use a standard queue for single-directional BFS
        var currentLevel: [String] = [beginWord]

        // Remove beginWord from the dictionary to avoid cycles and redundant processing
        wordSet.remove(beginWord)

        var step = 1
        let aAscii = Character("a").asciiValue!

        while !currentLevel.isEmpty {
            var nextLevel: [String] = []

            // Process all words in the current level
            for word in currentLevel {

                // Convert word to an array of characters for O(1) mutations
                var chars = Array(word)

                // Try substituting every character of the word with 'a' to 'z'
                for i in 0..<chars.count {
                    let originalChar = chars[i]

                    for j in 0..<26 {
                        let newChar = Character(UnicodeScalar(aAscii + UInt8(j)))   //IMPORTANT
                        if newChar == originalChar { continue }

                        chars[i] = newChar
                        let nextWord = String(chars)

                        // Early exit: if we hit the endWord, return the steps + 1
                        if nextWord == endWord {
                            return step + 1
                        }

                        // If it's a valid unvisited dictionary word, add it to the next level
                        if wordSet.contains(nextWord) {
                            nextLevel.append(nextWord)
                            wordSet.remove(nextWord) // Mark as visited
                        }
                    }

                    // Backtrack the character change before moving to the next position
                    chars[i] = originalChar
                }
            }

            // Move forward to the next level
            currentLevel = nextLevel
            step += 1
        }

        return 0
    }
}