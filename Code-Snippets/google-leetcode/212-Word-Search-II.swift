// 212. Word Search II
// Link: https://leetcode.com/problems/word-search-ii/
//
// Time Complexity: O(M * N * 4^L), where M * N is the board size and L is the maximum length of a word.
// Explanation: In the worst case, we start a backtracking search from every cell and explore up to 4 directions up to length L. The Trie heavily prunes this search.
// Space Complexity: O(W), where W is the total number of characters in all words.
// Explanation: The Trie takes space proportional to the sum of the lengths of all given words.

class TrieNode {
    var children: [Character: TrieNode] = [:]
    var word: String? = nil
}

class Solution {
    func findWords(_ board: [[Character]], _ words: [String]) -> [String] {
        let root = TrieNode()
        for word in words {
            var curr = root
            for char in word {
                if curr.children[char] == nil {
                    curr.children[char] = TrieNode()
                }
                curr = curr.children[char]!
            }
            curr.word = word
        }
        
        var board = board
        var result = Set<String>()
        let rows = board.count
        let cols = board[0].count
        
        func dfs(_ r: Int, _ c: Int, _ node: TrieNode) {
            if r < 0 || r >= rows || c < 0 || c >= cols || board[r][c] == "#" {
                return
            }
            
            let char = board[r][c]
            guard let nextNode = node.children[char] else { return }
            
            if let foundWord = nextNode.word {
                result.insert(foundWord)
                nextNode.word = nil // Prevent duplicates
            }
            
            board[r][c] = "#" // Mark as visited
            dfs(r + 1, c, nextNode)
            dfs(r - 1, c, nextNode)
            dfs(r, c + 1, nextNode)
            dfs(r, c - 1, nextNode)
            board[r][c] = char // Backtrack
            
            // Optimization: remove leaf nodes to prune search space
            if nextNode.children.isEmpty {
                node.children[char] = nil
            }
        }
        
        for r in 0..<rows {
            for c in 0..<cols {
                dfs(r, c, root)
            }
        }
        
        return Array(result)
    }
}
