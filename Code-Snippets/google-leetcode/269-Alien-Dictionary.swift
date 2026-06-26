// 269. Alien Dictionary
// Link: https://leetcode.com/problems/alien-dictionary/
//
// Time Complexity: O(C), where C is the total length of all the words in the input list.
// Explanation: Building the graph requires iterating through all characters of all words. The topological sort visits each character/edge at most once (bounded by 26 characters).
// Space Complexity: O(1) or O(U + E), where U is unique letters and E is relations.
// Explanation: Since the alphabet is fixed to 26 letters, the adjacency list and in-degree map take constant O(1) space.

class Solution {
    func alienOrder(_ words: [String]) -> String {
        var adj = [Character: [Character]]()
        var inDegree = [Character: Int]()
        
        // Initialize graphs for all unique characters
        for word in words {
            for char in word {
                inDegree[char] = 0
                adj[char] = []
            }
        }
        
        // Build the graph
        for i in 0..<(words.count - 1) {
            let w1 = Array(words[i])
            let w2 = Array(words[i + 1])
            let minLen = min(w1.count, w2.count)
            var foundDifference = false
            
            for j in 0..<minLen {
                let c1 = w1[j]
                let c2 = w2[j]
                
                if c1 != c2 {
                    adj[c1]?.append(c2)
                    inDegree[c2, default: 0] += 1
                    foundDifference = true
                    break
                }
            }
            
            // Invalid case: Prefix is placed after the longer word
            if !foundDifference && w1.count > w2.count {
                return ""
            }
        }
        
        // Topological sort using BFS (Kahn's Algorithm)
        var queue = [Character]()
        for (char, degree) in inDegree {
            if degree == 0 {
                queue.append(char)
            }
        }
        
        var result = ""
        while !queue.isEmpty {
            let char = queue.removeFirst()
            result.append(char)
            
            for neighbor in adj[char] ?? [] {
                inDegree[neighbor, default: 0] -= 1
                if inDegree[neighbor] == 0 {
                    queue.append(neighbor)
                }
            }
        }
        
        // If result does not contain all unique characters, there is a cycle
        if result.count != inDegree.count {
            return ""
        }
        
        return result
    }
}
