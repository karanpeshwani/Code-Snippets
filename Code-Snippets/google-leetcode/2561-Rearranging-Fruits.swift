// 2561-Rearranging-Fruits.swift
// 2561. Rearranging Fruits
// https://leetcode.com/problems/rearranging-fruits/
//
// Time Complexity: O(N log N) to sort the counts and the arrays of elements to swap.
// Space Complexity: O(N) to store frequencies and swap arrays.

class Solution {
    func minCost(_ basket1: [Int], _ basket2: [Int]) -> Int {
        var count = [Int: Int]()
        var minVal = Int.max
        
        for val in basket1 {
            count[val, default: 0] += 1
            minVal = min(minVal, val)
        }
        for val in basket2 {
            count[val, default: 0] -= 1
            minVal = min(minVal, val)
        }
        
        var toSwap = [Int]()
        for (val, diff) in count {
            if diff % 2 != 0 {
                return -1 // Impossible to balance
            }
            let swapsNeeded = abs(diff) / 2
            for _ in 0..<swapsNeeded {
                toSwap.append(val)
            }
        }
        
        toSwap.sort()
        var cost = 0
        let n = toSwap.count / 2
        for i in 0..<n {
            // We can either swap directly, or swap using the smallest element overall as a temporary buffer
            cost += min(toSwap[i], 2 * minVal)
        }
        
        return cost
    }
}
