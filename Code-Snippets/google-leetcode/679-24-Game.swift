// 679-24-Game.swift
// 679. 24 Game
// https://leetcode.com/problems/24-game/
//
// Time Complexity: O(1). Since the array size is always 4, there are at most 4! permutations and a limited number of ways to group the operations. We check all combinations in O(1) time.
// Space Complexity: O(1) as the recursion depth is at most 4.

class Solution {
    func judgePoint24(_ cards: [Int]) -> Bool {
        var doubles = cards.map { Double($0) }
        return solve(doubles)
    }
    
    func solve(_ list: [Double]) -> Bool {
        if list.count == 1 {
            return abs(list[0] - 24.0) < 1e-6
        }
        
        for i in 0..<list.count {
            for j in 0..<list.count {
                if i != j {
                    var nextList = [Double]()
                    for k in 0..<list.count {
                        if k != i && k != j {
                            nextList.append(list[k])
                        }
                    }
                    
                    let possibleResults = compute(list[i], list[j])
                    for res in possibleResults {
                        nextList.append(res)
                        if solve(nextList) {
                            return true
                        }
                        nextList.removeLast()
                    }
                }
            }
        }
        return false
    }
    
    func compute(_ a: Double, _ b: Double) -> [Double] {
        var res = [Double]()
        res.append(a + b)
        res.append(a - b)
        res.append(b - a)
        res.append(a * b)
        if abs(b) > 1e-6 { res.append(a / b) }
        if abs(a) > 1e-6 { res.append(b / a) }
        return res
    }
}
