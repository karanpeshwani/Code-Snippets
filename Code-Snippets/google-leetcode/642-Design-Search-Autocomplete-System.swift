// 642. Design Search Autocomplete System
// https://leetcode.com/problems/design-search-autocomplete-system/
//
// Time Complexity: 
//   - init: O(K * L), where K is the number of initial sentences and L is the average length of a sentence.
//   - input: O(P + Q log Q), where P is the length of the typed prefix and Q is the number of sentences passing through the current Trie node. Sorting takes O(Q log Q) but Q is relatively small.
// Space Complexity: O(N * L), where N is the total number of unique sentences and L is the average sentence length. We store nodes in the Trie and also keep all valid sentences associated with their prefixes.

class AutocompleteSystem {
    // A TrieNode keeps track of children and all full sentences that pass through this prefix
    class TrieNode {
        var children: [Character: TrieNode] = [:]
        var sentences: Set<String> = []
    }
    
    private let root = TrieNode()
    private var currNode: TrieNode
    private var currSentence = ""
    private var counts: [String: Int] = [:]
    
    init(_ sentences: [String], _ times: [Int]) {
        self.currNode = root
        for i in 0..<sentences.count {
            add(sentences[i], times[i])
        }
    }
    
    // Helper to add or update a sentence frequency
    private func add(_ sentence: String, _ count: Int) {
        counts[sentence, default: 0] += count
        var node = root
        
        for char in sentence {
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
            node.sentences.insert(sentence)
        }
    }
    
    func input(_ c: Character) -> [String] {
        if c == "#" {
            // End of sentence, add to system and reset state
            add(currSentence, 1)
            currSentence = ""
            currNode = root
            return []
        }
        
        currSentence.append(c)
        
        // If there's no node for the current character, create a dead-end essentially
        if currNode.children[c] == nil {
            currNode.children[c] = TrieNode()
        }
        
        currNode = currNode.children[c]!
        
        // Sort the sentences matching the prefix by frequency descending, then ASCII ascending
        let sortedSentences = currNode.sentences.sorted {
            let count1 = counts[$0]!
            let count2 = counts[$1]!
            if count1 == count2 {
                return $0 < $1
            }
            return count1 > count2
        }
        
        // Return top 3 hot sentences
        return Array(sortedSentences.prefix(3))
    }
}
