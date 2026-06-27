// 843. Guess the Word
// https://leetcode.com/problems/guess-the-word

// Time Complexity: O(N^2) where N is the number of candidates. In each iteration we compare all pairs to find the minimax score. There are at most 10 iterations. For N = 100, N^2 is 10,000 comparisons per guess, which is extremely fast.
// Space Complexity: O(N) to store the list of candidate words.

/**
 * // This is the Master's API interface.
 * // You should not implement it, or speculate about its implementation
 * class Master {
 *     public func guess(word: String) -> Int {}
 * }
 */

class Solution {
    func findSecretWord(_ words: [String], _ master: Master) {
        var candidates = words
        
        // We have at most 10 guesses
        for _ in 0..<10 {
            // Select the word that minimizes the maximum possible group of remaining words
            let guessWord = getBestWord(candidates)
            let matches = master.guess(guessWord)
            
            // If we found the word, we can return
            if matches == 6 {
                return
            }
            
            // Filter candidates to only those that have the exact same number of matches
            // with our guess word as the secret word did.
            candidates = candidates.filter { match(guessWord, $0) == matches }
        }
    }
    
    // Finds the word that will leave us with the smallest possible worst-case list of candidates
    private func getBestWord(_ candidates: [String]) -> String {
        var bestWord = ""
        var minMaxGroupSize = Int.max
        
        for word1 in candidates {
            // Count how many words would be left for each possible number of matches (0...6)
            var groupCounts = [Int](repeating: 0, count: 7)
            for word2 in candidates {
                if word1 != word2 {
                    groupCounts[match(word1, word2)] += 1
                }
            }
            
            // Find the size of the largest group of words that could remain
            let maxGroupSize = groupCounts.max() ?? 0
            
            // We want to minimize this largest group
            if maxGroupSize < minMaxGroupSize {
                minMaxGroupSize = maxGroupSize
                bestWord = word1
            }
        }
        
        // If there is only one candidate, bestWord will remain empty unless we handle it,
        // but the loop will just assign bestWord = word1 since maxGroupSize will be 0.
        return bestWord.isEmpty ? candidates[0] : bestWord
    }
    
    // Helper function to count exact matches between two words
    private func match(_ word1: String, _ word2: String) -> Int {
        let w1 = Array(word1.utf8)
        let w2 = Array(word2.utf8)
        var matches = 0
        for i in 0..<6 {
            if w1[i] == w2[i] {
                matches += 1
            }
        }
        return matches
    }
}
