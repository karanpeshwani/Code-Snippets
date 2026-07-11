// 1442. Count Triplets That Can Form Two Arrays of Equal XOR
// https://leetcode.com/problems/count-triplets-that-can-form-two-arrays-of-equal-xor/

/*
 Intuition:
 We need to find triplets (i, j, k) such that the XOR of `arr[i...j-1]` equals the XOR of `arr[j...k]`.
 Let `A = arr[i] ^ ... ^ arr[j-1]` and `B = arr[j] ^ ... ^ arr[k]`.
 The condition `A == B` is mathematically equivalent to `A ^ B == 0`.
 This means the XOR of the entire subarray `arr[i...k]` must be 0.
 If we find a subarray `arr[i...k]` that XORs to 0, any index `j` strictly between `i` and `k` (where `i < j <= k`)
 will split it into two halves that have equal XORs. For a valid pair (i, k), there are exactly `k - i` valid `j`s.
 We can use a prefix XOR array where `prefix[x]` is the XOR of elements up to index `x-1`.
 A subarray `arr[i...k]` XORs to 0 if `prefix[i] == prefix[k+1]`.
 To optimize to O(N), for each prefix XOR value, we can keep track of how many times we've seen it (`count`) 
 and the sum of the indices where we saw it (`totalSum`). When we see the same prefix XOR at index `k+1`, 
 it can form triplets with all previous occurrences. The total triplets added is `count * k - totalSum`.

 Time Complexity: O(N)
 - N is the length of the array. We iterate through the array once.
 - Each iteration involves O(1) dictionary lookups and updates.
 - Total time complexity is O(N).

 Space Complexity: O(N)
 - We use two dictionaries to store the counts and the sum of indices for each prefix XOR value.
 - Overall space complexity is O(N).
 */

class Solution {
    func countTriplets(_ arr: [Int]) -> Int {
        var countMap = [Int: Int]()
        var sumMap = [Int: Int]()
        
        // Base case: prefix XOR of 0 at index 0 (before the first element)
        countMap[0] = 1
        sumMap[0] = 0
        
        var prefix = 0
        var triplets = 0
        
        for k in 0..<arr.count {
            prefix ^= arr[k]
            
            if let count = countMap[prefix], let totalSum = sumMap[prefix] {
                // If we have seen this prefix before at index i, arr[i...k] XORs to 0
                // We add `k - i` for each previous occurrence.
                triplets += count * k - totalSum
            }
            
            // Store the current prefix XOR and its index (k + 1) for future reference
            countMap[prefix, default: 0] += 1
            sumMap[prefix, default: 0] += (k + 1)
        }
        
        return triplets
    }
}
