// 818. Race Car
// https://leetcode.com/problems/race-car
// Time Complexity: O(T * log(T)), where T is the target. The DP solves subproblems for each target up to T, and for each target it iterates at most log(T) times.
// Space Complexity: O(T), to store the DP memoization table up to size T.

class Solution {
    // Memoization table to store minimum instructions for a given target distance
    var memo = [Int: Int]()
    
    func racecar(_ target: Int) -> Int {
        // Base case: already at the target
        if target == 0 { return 0 }
        
        // Return cached result if already computed
        if let val = memo[target] { return val }
        
        // Find n such that 2^{n-1} <= target < 2^n
        var n = 0
        while (1 << n) - 1 < target {
            n += 1
        }
        
        // If target is exactly 2^n - 1, we just accelerate n times.
        if (1 << n) - 1 == target {
            memo[target] = n
            return n
        }
        
        // Option 1: Drive past the target and reverse.
        // We go 2^n - 1 (which takes n 'A's), then reverse ('R'), 
        // and then we need to reach the target backwards.
        var ans = racecar((1 << n) - 1 - target) + n + 1
        
        // Option 2: Drive just short of target, reverse, drive a bit, reverse again, and then go forward.
        // We go 2^{n-1} - 1 (takes (n-1) 'A's), then reverse ('R'), 
        // accelerate m times (m 'A's), reverse ('R'), 
        // and then solve for the remaining distance.
        for m in 0..<(n - 1) {
            let remainingDistance = target - (1 << (n - 1)) + (1 << m)
            ans = min(ans, racecar(remainingDistance) + n - 1 + 1 + m + 1)
        }
        
        memo[target] = ans
        return ans
    }
}
