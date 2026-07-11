// 642. Design Search Autocomplete System
// https://leetcode.com/problems/design-search-autocomplete-system/

/*
 Intuition:
 We need a system that, as a user types character by character, returns the top 3 most frequently typed
 sentences matching the current prefix. Two key operations are needed:
   1. Prefix lookup: Find all stored sentences matching a given prefix → use a Trie.
   2. Ranking: Among matched sentences, return top 3 by frequency (desc), then by ASCII order (asc).

 The Trie approach works as follows:
 - Each TrieNode stores references to its children.
 - Each node also stores a sorted list of (sentence, count) candidates that pass through it.
   This allows O(1) ranked retrieval at each prefix node instead of scanning all sentences.
 - We maintain a pointer `currNode` that walks the Trie as the user types, avoiding redundant prefix traversals.
 - When '#' is typed, the completed sentence is inserted/updated in the Trie and the state resets.

 Key Optimization — Pre-sorted candidates at each node:
 - Instead of sorting at query time, each TrieNode stores its top candidates already sorted.
 - On each `input()` call, we walk only one level deeper in the Trie (O(1) traversal).
 - The only sorting happens at insertion time when `add()` is called (bounded per-node).

 Time Complexity:
   - init: O(K * L * L) where K = number of initial sentences, L = average sentence length.
     Each character insertion may trigger re-sorting the candidate list at that node.
   - input (non-#): O(L) amortized — just advance the pointer and return the pre-sorted list.
   - input ('#'): O(L * L) — insert the new sentence into L nodes, each sorts its candidate list.

 Space Complexity: O(N * L * L)
   - N = total unique sentences, L = average sentence length.
   - The Trie has O(N * L) nodes total.
   - Each node can store up to N candidate sentences, but across all nodes the total storage is O(N * L).
 */

class AutocompleteSystem {

    // MARK: - Trie Node
    // Each node stores:
    //   • children: mapping from Character to next TrieNode
    //   • candidates: pre-sorted list of (sentence, count) tuples for O(1) top-3 retrieval
    class TrieNode {
        var children = [Character: TrieNode]()
        // Sorted: descending by count, then ascending by ASCII for equal counts
        var candidates = [(sentence: String, count: Int)]()
    }

    // MARK: - Properties
    private let root = TrieNode()
    private var currNode: TrieNode        // pointer that walks during a user session
    private var currSentence = ""         // sentence typed so far in the current session
    private var isDeadEnd = false         // true if the user typed a char with no Trie path
    private var counts = [String: Int]()  // global frequency map for all sentences

    // MARK: - Init
    init(_ sentences: [String], _ times: [Int]) {
        currNode = root
        for i in 0..<sentences.count {
            add(sentences[i], times[i])
        }
    }

    // MARK: - Private Helpers

    /// Inserts or updates `sentence` with `count` additional occurrences throughout the Trie.
    private func add(_ sentence: String, _ count: Int) {
        counts[sentence, default: 0] += count
        let finalCount = counts[sentence]!
        var node = root

        for char in sentence {
            // Create child node if missing
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!

            // Update or insert this sentence in the node's candidate list
            if let idx = node.candidates.firstIndex(where: { $0.sentence == sentence }) {
                node.candidates[idx].count = finalCount
            } else {
                node.candidates.append((sentence, finalCount))
            }

            // Keep the candidate list sorted:
            // • Descending by count (hottest first)
            // • Ascending by ASCII for ties
            node.candidates.sort {
                $0.count != $1.count ? $0.count > $1.count : $0.sentence < $1.sentence
            }
        }
    }

    // MARK: - Public API

    /// Called for each typed character.
    /// Returns top 3 matching hot sentences, or [] if c == '#'.
    func input(_ c: Character) -> [String] {
        if c == "#" {
            // Sentence is complete — persist it and reset session state
            add(currSentence, 1)
            currSentence = ""
            currNode = root
            isDeadEnd = false
            return []
        }

        currSentence.append(c)

        // Once we've hit a dead end (no Trie path), stay dead until '#' resets us
        if isDeadEnd {
            return []
        }

        // Walk one level deeper in the Trie
        if let nextNode = currNode.children[c] {
            currNode = nextNode
        } else {
            // Character not in Trie — no matches possible for this or future characters
            isDeadEnd = true
            return []
        }

        // Return pre-sorted top-3 sentences at this prefix node
        return currNode.candidates.prefix(3).map { $0.sentence }
    }
}

/**
 * Usage Example:
 * let obj = AutocompleteSystem(["i love you", "island", "iroman", "i love leetcode"], [5, 3, 2, 2])
 * obj.input("i")   // → ["i love you", "island", "i love leetcode"]
 * obj.input(" ")   // → ["i love you", "i love leetcode"]
 * obj.input("a")   // → []
 * obj.input("#")   // → []  (stores "i a" with count 1)
 */
