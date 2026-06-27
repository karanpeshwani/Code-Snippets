// 2791-Count-Paths-That-Can-Form-a-Palindrome-in-a-Tree.swift
// 2791. Count Paths That Can Form a Palindrome in a Tree
// https://leetcode.com/problems/count-paths-that-can-form-a-palindrome-in-a-tree/
//
// Time Complexity: O(N) since we perform a DFS to find the bitmask for each node from the root.
// Hash map operations take O(1) on average.
// Space Complexity: O(N) to store the tree and the frequency map of bitmasks.

class Solution {
    func countPalindromePaths(_ parent: [Int], _ s: String) -> Int {
        let n = parent.count
        var tree = [Int: [(Int, Int)]]()
        let chars = Array(s)
        
        for i in 1..<n {
            let p = parent[i]
            let charValue = Int(chars[i].asciiValue! - Character("a").asciiValue!)
            tree[p, default: []].append((i, charValue))
        }
        
        var maskFreq = [Int: Int]()
        var res = 0
        
        func dfs(_ node: Int, _ mask: Int) {
            // Check for exact same mask (all characters even)
            res += maskFreq[mask, default: 0]
            
            // Check for masks that differ by exactly one bit (one character odd)
            for i in 0..<26 {
                let toggledMask = mask ^ (1 << i)
                res += maskFreq[toggledMask, default: 0]
            }
            
            maskFreq[mask, default: 0] += 1
            
            for (child, charValue) in tree[node, default: []] {
                dfs(child, mask ^ (1 << charValue))
            }
        }
        
        dfs(0, 0)
        return res
    }
}
