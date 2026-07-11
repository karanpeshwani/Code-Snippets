// 1707. Maximum XOR With an Element From Array
// https://leetcode.com/problems/maximum-xor-with-an-element-from-array/

/*
 Intuition:
 For each query `[x, m]`, we want to find an element `v` in `nums` such that `v <= m` and `x ^ v` is maximized.
 To maximize the XOR efficiently, we can use a Trie (Prefix Tree) where each node represents a bit (0 or 1).
 Because the queries have a condition `v <= m`, we can't just put all elements of `nums` into the Trie immediately.
 Instead, we can process the queries offline. 
 1. Sort the `nums` array in ascending order.
 2. Sort the queries in ascending order of their `m` value (remembering their original indices).
 3. For each query, insert elements from `nums` into the Trie as long as they are `<= m`.
 4. After inserting, query the Trie for the maximum XOR with `x`.
 If the Trie is empty (no elements `<= m`), the answer for that query is -1.

 Time Complexity: O(N log N + Q log Q + (N + Q) * 32)
 - Sorting `nums` takes O(N log N).
 - Sorting queries takes O(Q log Q).
 - Inserting N elements into the Trie takes O(N * 32).
 - Querying the Trie for Q queries takes O(Q * 32).
 - Total time complexity is dominated by sorting and Trie operations.

 Space Complexity: O(N * 32 + Q)
 - The Trie can have up to N * 32 nodes.
 - We store the queries and the result array of size Q.
 - Overall space complexity is O(N * 32 + Q).
 */

class Solution {
    class TrieNode {
        var children = [TrieNode?](repeating: nil, count: 2)
    }
    
    class Trie {
        let root = TrieNode()
        
        func insert(_ num: Int) {
            var node = root
            for i in stride(from: 31, through: 0, by: -1) {
                let bit = (num >> i) & 1
                if node.children[bit] == nil {
                    node.children[bit] = TrieNode()
                }
                node = node.children[bit]!
            }
        }
        
        func getMaxXor(with x: Int) -> Int {
            var node = root
            var maxXor = 0
            
            for i in stride(from: 31, through: 0, by: -1) {
                let bit = (x >> i) & 1
                let flippedBit = 1 - bit
                
                // If the flipped bit exists, go that way to maximize XOR (1)
                if let child = node.children[flippedBit] {
                    maxXor |= (1 << i)
                    node = child
                } else if let child = node.children[bit] {
                    // Otherwise, go the same bit way (XOR is 0)
                    node = child
                } else {
                    return -1 // Trie is empty
                }
            }
            return maxXor
        }
    }
    
    func maximizeXor(_ nums: [Int], _ queries: [[Int]]) -> [Int] {
        let sortedNums = nums.sorted()
        
        // Attach original indices to queries before sorting
        let sortedQueries = queries.enumerated().map { (index, query) in
            return (originalIndex: index, x: query[0], m: query[1])
        }.sorted { $0.m < $1.m }
        
        var result = Array(repeating: -1, count: queries.count)
        let trie = Trie()
        var numIdx = 0
        let n = sortedNums.count
        
        for q in sortedQueries {
            // Insert all valid numbers into the Trie
            while numIdx < n && sortedNums[numIdx] <= q.m {
                trie.insert(sortedNums[numIdx])
                numIdx += 1
            }
            
            if numIdx == 0 {
                result[q.originalIndex] = -1
            } else {
                result[q.originalIndex] = trie.getMaxXor(with: q.x)
            }
        }
        
        return result
    }
}
