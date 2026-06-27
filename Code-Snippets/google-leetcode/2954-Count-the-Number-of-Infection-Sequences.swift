// 2954-Count-the-Number-of-Infection-Sequences.swift
// 2954. Count the Number of Infection Sequences
// https://leetcode.com/problems/count-the-number-of-infection-sequences/
//
// Time Complexity: O(N) to precompute factorials and modular inverses. Finding gaps and calculating the result takes O(M) where M is the number of sick children. Overall O(N).
// Space Complexity: O(N) to store factorials for calculating combinations.

class Solution {
    func numberOfSequence(_ n: Int, _ sick: [Int]) -> Int {
        let mod = 1_000_000_007
        
        var fact = Array(repeating: 1, count: n + 1)
        var invFact = Array(repeating: 1, count: n + 1)
        
        func power(_ base: Int, _ exp: Int) -> Int {
            var res = 1
            var b = base % mod
            var e = exp
            while e > 0 {
                if e % 2 == 1 {
                    res = (res * b) % mod
                }
                b = (b * b) % mod
                e /= 2
            }
            return res
        }
        
        for i in 1...n {
            fact[i] = (fact[i - 1] * i) % mod
        }
        invFact[n] = power(fact[n], mod - 2)
        for i in stride(from: n - 1, through: 0, by: -1) {
            invFact[i] = (invFact[i + 1] * (i + 1)) % mod
        }
        
        var totalEmpty = 0
        var res = 1
        var emptySegments = [Int]()
        
        // Count empty segments and add ways for middle segments
        if sick[0] > 0 {
            emptySegments.append(sick[0])
            totalEmpty += sick[0]
        }
        
        for i in 1..<sick.count {
            let gap = sick[i] - sick[i - 1] - 1
            if gap > 0 {
                emptySegments.append(gap)
                totalEmpty += gap
                // For a gap between two sick children of length K, there are 2^(K-1) ways to infect them
                res = (res * power(2, gap - 1)) % mod
            }
        }
        
        let lastGap = n - 1 - sick.last!
        if lastGap > 0 {
            emptySegments.append(lastGap)
            totalEmpty += lastGap
        }
        
        // The total number of valid sequences is formed by interleaving the moves for each segment
        // Total ways is (totalEmpty)! / (gap1! * gap2! * ...) * 2^(gap_length - 1 for middle gaps)
        res = (res * fact[totalEmpty]) % mod
        for gap in emptySegments {
            res = (res * invFact[gap]) % mod
        }
        
        return res
    }
}
