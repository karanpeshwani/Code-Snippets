// 564-Find-the-Closest-Palindrome.swift
// 564. Find the Closest Palindrome
// https://leetcode.com/problems/find-the-closest-palindrome/
//
// Time Complexity: O(L), where L is the length of the string n. The length is at most 18, so this is effectively O(1).
// Generating the candidates involves string manipulations of length L.
// Space Complexity: O(L) to store the string prefix and the candidates, which is also effectively O(1).

class Solution {
    func nearestPalindromic(_ n: String) -> String {
        let L = n.count
        var candidates = Set<Int>()
        
        // Edge case 1: 10^(L-1) - 1 (e.g., 1000 -> 999)
        if L > 1 {
            let str1 = String(repeating: "9", count: L - 1)
            if let val = Int(str1) { candidates.insert(val) }
        } else {
            candidates.insert(0)
        }
        
        // Edge case 2: 10^L + 1 (e.g., 999 -> 1001)
        let str2 = "1" + String(repeating: "0", count: max(0, L - 1)) + "1"
        if let val = Int(str2) { candidates.insert(val) }
        
        // Candidates by modifying the middle part of the number
        let prefixStr = String(n.prefix((L + 1) / 2))
        if let P = Int(prefixStr) {
            for i in -1...1 {
                let newPrefix = String(P + i)
                var candidateStr = newPrefix
                let reversedSuffix = String(newPrefix.reversed())
                
                // If the length is odd, we avoid duplicating the middle character
                if L % 2 == 1 {
                    candidateStr += reversedSuffix.dropFirst()
                } else {
                    candidateStr += reversedSuffix
                }
                
                if let val = Int(candidateStr) {
                    candidates.insert(val)
                }
            }
        }
        
        // Remove the original number itself from candidates
        guard let originalNum = Int(n) else { return "" }
        candidates.remove(originalNum)
        
        var minDiff = Int.max
        var res = Int.max
        
        // Find the candidate with the minimum absolute difference
        for cand in candidates {
            let diff = abs(cand - originalNum)
            if diff < minDiff {
                minDiff = diff
                res = cand
            } else if diff == minDiff {
                res = min(res, cand) // Resolve ties by choosing the smaller number
            }
        }
        
        return String(res)
    }
}
