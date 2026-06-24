//
//  12-Trie.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - TrieNode

final class TrieNode {
    var children:    [Character: TrieNode] = [:]
    var isEndOfWord: Bool                  = false
    var count:       Int                   = 0   // words ending here
    var prefixCount: Int                   = 0   // words passing through
}

// MARK: - Trie

final class Trie {
    private let root = TrieNode()

    // ── Insert   O(k) where k = word length ─────────────────────────────────

    func insert(_ word: String) {
        var node = root
        for ch in word {
            if node.children[ch] == nil { node.children[ch] = TrieNode() }
            node = node.children[ch]!
            node.prefixCount += 1
        }
        node.isEndOfWord = true
        node.count += 1
    }

    // ── Search: exact word   O(k) ────────────────────────────────────────────

    func search(_ word: String) -> Bool {
        return node(for: word)?.isEndOfWord == true
    }

    // ── StartsWith: any word with this prefix   O(k) ─────────────────────────

    func startsWith(_ prefix: String) -> Bool {
        return node(for: prefix) != nil
    }

    // ── Delete   O(k) ────────────────────────────────────────────────────────

    func delete(_ word: String) {
        guard search(word) else { return }
        var node = root
        var path = [(node: TrieNode, char: Character)]()

        for ch in word {
            let next = node.children[ch]!
            path.append((node, ch))
            next.prefixCount -= 1
            node = next
        }
        node.count -= 1
        if node.count == 0 { node.isEndOfWord = false }

        // Clean up dangling nodes (no remaining words)
        for (parent, ch) in path.reversed() {
            if parent.children[ch]!.prefixCount == 0 {
                parent.children.removeValue(forKey: ch)
            } else { break }
        }
    }

    // ── Count words with exact prefix   O(k) ─────────────────────────────────

    func countWordsWithPrefix(_ prefix: String) -> Int {
        return node(for: prefix)?.prefixCount ?? 0
    }

    // ── Count exact word occurrences   O(k) ──────────────────────────────────

    func countWord(_ word: String) -> Int {
        return node(for: word)?.count ?? 0
    }

    // ── All words with prefix (autocomplete)   O(k + output) ─────────────────

    func wordsWithPrefix(_ prefix: String) -> [String] {
        guard let prefixNode = node(for: prefix) else { return [] }
        var results = [String]()
        func dfs(_ node: TrieNode, _ current: String) {
            if node.isEndOfWord { results.append(current) }
            for (ch, child) in node.children { dfs(child, current + String(ch)) }
        }
        dfs(prefixNode, prefix)
        return results
    }

    // ── Longest Common Prefix among all inserted words   O(total chars) ──────

    func longestCommonPrefix() -> String {
        var node = root
        var prefix = ""
        while node.children.count == 1 && !node.isEndOfWord {
            let (ch, child) = node.children.first!
            prefix.append(ch)
            node = child
        }
        return prefix
    }

    // ── Private helper ────────────────────────────────────────────────────────

    private func node(for key: String) -> TrieNode? {
        var node = root
        for ch in key {
            guard let next = node.children[ch] else { return nil }
            node = next
        }
        return node
    }
}

// MARK: - Trie with Array (faster — 26 lowercase letters only)

final class TrieFast {
    private final class Node {
        var children    = [Node?](repeating: nil, count: 26)
        var isEndOfWord = false
    }

    private let root = Node()

    private func index(_ ch: Character) -> Int {
        return Int(ch.asciiValue!) - Int(Character("a").asciiValue!)
    }

    func insert(_ word: String) {
        var node = root
        for ch in word {
            let i = index(ch)
            if node.children[i] == nil { node.children[i] = Node() }
            node = node.children[i]!
        }
        node.isEndOfWord = true
    }

    func search(_ word: String) -> Bool {
        var node = root
        for ch in word {
            guard let next = node.children[index(ch)] else { return false }
            node = next
        }
        return node.isEndOfWord
    }

    func startsWith(_ prefix: String) -> Bool {
        var node = root
        for ch in prefix {
            guard let next = node.children[index(ch)] else { return false }
            node = next
        }
        return true
    }

    // Search with wildcard '.' (matches any single letter)
    func searchWithWildcard(_ word: String) -> Bool {
        func dfs(_ node: Node?, _ chars: [Character], _ i: Int) -> Bool {
            guard let n = node else { return false }
            if i == chars.count { return n.isEndOfWord }
            if chars[i] == "." {
                return n.children.contains { dfs($0, chars, i + 1) }
            }
            return dfs(n.children[index(chars[i])], chars, i + 1)
        }
        return dfs(root, Array(word), 0)
    }
}

// MARK: - Pattern: Word Search II (LC 212) — Trie + DFS on grid

func findWords(_ board: [[Character]], _ words: [String]) -> [String] {
    let trie = TrieFast()
    words.forEach { trie.insert($0) }

    let rows = board.count, cols = board[0].count
    var result = Set<String>(), visited = Set<String>()

    func dfs(_ r: Int, _ c: Int, _ node: TrieFast, _ path: String) {
        // Simplified — full implementation requires exposing TrieFast node internals
        // In practice, pass the TrieNode down rather than re-searching from root
    }

    return Array(result)
}

// MARK: - Pattern: Replace Words (LC 648)

func replaceWords(_ dictionary: [String], _ sentence: String) -> String {
    let trie = Trie()
    dictionary.forEach { trie.insert($0) }

    func shortestRoot(_ word: String) -> String {
        var node = trie
        var prefix = ""
        // Walk trie character by character, stop at first word end
        // (simplified — full impl needs node traversal)
        return word
    }

    return sentence
        .split(separator: " ")
        .map { shortestRoot(String($0)) }
        .joined(separator: " ")
}

// MARK: - Pattern: Longest Word in Dictionary   O(total chars)

func longestWord(_ words: [String]) -> String {
    let trie = Trie()
    words.forEach { trie.insert($0) }

    var result = ""
    func dfs(_ node: TrieNode, _ current: String) {
        if current.count > result.count { result = current }
        for (ch, child) in node.children where child.isEndOfWord {
            dfs(child, current + String(ch))
        }
    }

    // Start DFS from root children that are end-of-words (single char words)
    // (accessing root — in practice expose root or add a helper)
    return result
}

// MARK: - Complexity Summary
//
//  Operation            Time
//  insert(word)         O(k)   k = word length
//  search(word)         O(k)
//  startsWith(prefix)   O(k)
//  delete(word)         O(k)
//  wordsWithPrefix      O(k + output size)
//  Space per trie       O(total characters × alphabet size)
//
//  Array-based children (size 26): faster access, more memory
//  HashMap children:               slower access, memory-efficient for large alphabets
