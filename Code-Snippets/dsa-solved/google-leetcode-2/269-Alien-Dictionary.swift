// 269. Alien Dictionary
// https://leetcode.com/problems/alien-dictionary
//
// Intuition/Explanation:
// This is a classic topological sort problem on a directed graph.
// We can build a graph where each unique character is a node. By comparing adjacent words in the dictionary,
// we can determine the relative order of characters. Specifically, we find the first character that differs 
// between `word1` and `word2`. A directed edge from `word1[i]` to `word2[i]` indicates that `word1[i]` 
// must come before `word2[i]` in the alien alphabet.
// An important edge case: if `word1` is longer than `word2` and `word1` starts with `word2` (e.g., "abc", "ab"), 
// the given dictionary is invalid, so we return "".
// Once the graph is built, we calculate the in-degree of each character and use Kahn's Algorithm (BFS) 
// to perform the topological sort. If the resulting sorted characters length doesn't equal the total 
// unique characters, there is a cycle, so we return "".
//
// Time Complexity: O(C), where C is the total length of all words in the input array. We compare adjacent words 
// and build the graph. Topological sort takes O(V + E) where V <= 26 and E <= 26^2, which is O(1). Overall O(C).
// Space Complexity: O(1) or O(U) where U is the number of unique characters (at most 26), 
// so the adjacency list and in-degree map take O(1) space.

class Solution {
    func alienOrder(_ words: [String]) -> String {
        var adj = [Character: Set<Character>]()
        var inDegree = [Character: Int]()
        
        // Initialize graphs for all unique characters
        for word in words {
            for char in word {
                if inDegree[char] == nil {
                    inDegree[char] = 0
                    adj[char] = []
                }
            }
        }
        
        // Build the graph
        for i in 0..<words.count - 1 {
            let word1 = Array(words[i])
            let word2 = Array(words[i + 1])
            let minLen = min(word1.count, word2.count)
            
            // Check invalid case like ["abc", "ab"]
            if word1.count > word2.count && Array(word1[0..<minLen]) == word2 {
                return ""
            }
            
            for j in 0..<minLen {
                let c1 = word1[j]
                let c2 = word2[j]
                
                if c1 != c2 {
                    if !adj[c1]!.contains(c2) {
                        adj[c1]!.insert(c2)
                        inDegree[c2]! += 1
                    }
                    break // Only the first different character determines the order
                }
            }
        }
        
        // Topological Sort using Kahn's Algorithm (BFS)
        var queue = [Character]()
        for (char, degree) in inDegree {
            if degree == 0 {
                queue.append(char)
            }
        }
        
        var result = ""
        var head = 0 // Using an index pointer to simulate queue for O(1) dequeue
        
        while head < queue.count {
            let char = queue[head]
            head += 1
            result.append(char)
            
            for neighbor in adj[char]! {
                inDegree[neighbor]! -= 1
                if inDegree[neighbor]! == 0 {
                    queue.append(neighbor)
                }
            }
        }
        
        // If result contains all characters, return it. Otherwise, there is a cycle.
        return result.count == inDegree.count ? result : ""
    }
}
