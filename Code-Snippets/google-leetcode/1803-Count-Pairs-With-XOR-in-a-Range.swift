// 1803. Count Pairs With XOR in a Range
// https://leetcode.com/problems/count-pairs-with-xor-in-a-range

// Time Complexity: O(N * L) where N is the number of elements in nums and L is the number of bits (15).
// We iterate over the array once. For each element, we query the Trie twice (for high and low - 1) and then insert it into the Trie,
// both taking O(L) time. Thus, the total time complexity is bounded by O(N * L).
// Space Complexity: O(N * L) for storing the Trie nodes. In the worst case, each insertion can add up to L new nodes.

class Solution {
    class TrieNode {
        var children: [TrieNode?] = [nil, nil]
        var count: Int = 0
    }
    
    // We only need 15 bits because the maximum number in nums is 20000.
    // 2^14 = 16384, 2^15 = 32768. So bit indices from 14 down to 0 cover up to 32767.
    private let maxBit = 14
    private var root = TrieNode()
    
    func countPairs(_ nums: [Int], _ low: Int, _ high: Int) -> Int {
        var pairs = 0
        root = TrieNode() // Reset root for each call if the instance is reused
        
        for num in nums {
            // Count pairs (num, x) already in Trie such that x ^ num <= high
            let highCount = countPairsLessEqual(num, high)
            // Count pairs (num, x) already in Trie such that x ^ num <= low - 1
            let lowCount = countPairsLessEqual(num, low - 1)
            
            pairs += (highCount - lowCount)
            
            // Insert current number into Trie to be used by subsequent numbers
            insert(num)
        }
        
        return pairs
    }
    
    private func insert(_ num: Int) {
        var curr = root
        for i in stride(from: maxBit, through: 0, by: -1) {
            let bit = (num >> i) & 1
            if curr.children[bit] == nil {
                curr.children[bit] = TrieNode()
            }
            curr = curr.children[bit]!
            curr.count += 1
        }
    }
    
    private func countPairsLessEqual(_ num: Int, _ limit: Int) -> Int {
        var count = 0
        var curr: TrieNode? = root
        
        for i in stride(from: maxBit, through: 0, by: -1) {
            guard let node = curr else { break }
            
            let numBit = (num >> i) & 1
            let limitBit = (limit >> i) & 1
            
            if limitBit == 1 {
                // If limit bit is 1, having an XOR of 0 at this bit makes the resulting number strictly smaller than the limit.
                // We add the count of the branch that results in an XOR of 0 (which is the branch matching numBit).
                if let childZeroXor = node.children[numBit] {
                    count += childZeroXor.count
                }
                // Then, we move down the branch that results in an XOR of 1 to keep comparing next bits.
                curr = node.children[1 - numBit]
            } else {
                // If limit bit is 0, we must match the bit exactly to keep the XOR at 0 so far.
                // Any other choice would make the XOR 1, which is greater than the limit bit.
                curr = node.children[numBit]
            }
        }
        
        // Don't forget to add the elements that exactly match the limit at the end of the Trie
        if let node = curr {
            count += node.count
        }
        
        return count
    }
}
