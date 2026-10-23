// 126. Word Ladder II
// https://leetcode.com/problems/word-ladder-ii

/*
 Intuition/Explanation:
 We need to find all shortest transformation sequences. This can be broken down into two parts:
 1. BFS (Breadth-First Search) to find the shortest path length and build a graph of parent pointers. 
    We traverse level by level. To ensure we find all shortest paths, words are removed from the 
    unvisited set only after the entire current level finishes processing.
    For each word, we try changing every character and check if it exists in the word list.
 2. DFS (Depth-First Search) for backtracking. Once BFS reaches the `endWord`, we start from `endWord` 
    and backtrack to `beginWord` using the parent pointers, prepending words to form valid paths.

 Time Complexity: O(N * L^2 + V + E), where N is the number of words in the list, and L is the word length.
 Generating neighbors takes O(L * 26) per word. DFS takes time proportional to the number of shortest paths.
 Space Complexity: O(N * L) for storing the words in sets, the BFS queue, and the adjacency list (parent graph).
*/

class Solution {
    func findLadders(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> [[String]] {
        var wordSet = Set(wordList)
        if !wordSet.contains(endWord) { return [] }
        
        var parents = [String: [String]]()
        var currentLevel = Set([beginWord])
        wordSet.remove(beginWord)
        
        var found = false
        
        // Step 1: BFS to build the parent graph
        while !currentLevel.isEmpty && !found {
            for word in currentLevel {
                wordSet.remove(word)
            }
            
            var nextLevel = Set<String>()
            
            for word in currentLevel {
                let chars = Array(word)
                
                for i in 0..<chars.count {
                    var modifiedChars = chars
                    for charCode in 97...122 { // 'a' to 'z'
                        let c = Character(UnicodeScalar(charCode)!)
                        if chars[i] == c { continue }
                        
                        modifiedChars[i] = c
                        let nextWord = String(modifiedChars)
                        
                        if wordSet.contains(nextWord) {
                            nextLevel.insert(nextWord)
                            parents[nextWord, default: []].append(word)
                            if nextWord == endWord {
                                found = true
                            }
                        }
                    }
                }
            }
            currentLevel = nextLevel
        }
        
        // Step 2: DFS to reconstruct paths
        var results = [[String]]()
        if found {
            var path = [endWord]
            dfs(endWord, beginWord, parents, &path, &results)
        }
        
        return results
    }
    
    private func dfs(_ currentWord: String, _ beginWord: String, _ parents: [String: [String]], _ path: inout [String], _ results: inout [[String]]) {
        if currentWord == beginWord {
            results.append(path.reversed())
            return
        }
        
        if let currentParents = parents[currentWord] {
            for parent in currentParents {
                path.append(parent)
                dfs(parent, beginWord, parents, &path, &results)
                path.removeLast()
            }
        }
    }
}
