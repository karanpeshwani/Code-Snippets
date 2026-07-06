// 149. Max Points on a Line
// https://leetcode.com/problems/max-points-on-a-line

/*
 Intuition/Explanation:
 Two points determine a line. For each point `i`, we can calculate the slope of the line 
 connecting it to every other point `j`. All points `j` that have the same slope with point `i` 
 lie on the same line passing through point `i`.
 We use a hash map to keep track of the frequencies of each slope originating from point `i`.
 To avoid precision issues with floating-point numbers when representing slopes, we store the 
 slope as an irreducible fraction `(dy / dx)`. We divide `dy` and `dx` by their Greatest Common Divisor (GCD).
 For each point `i`, the maximum points on a line through it is `max(frequencies) + 1` (adding point `i` itself).

 Time Complexity: O(N^2), where N is the number of points. We compute the slope for all pairs of points.
 The GCD operation takes O(log(min(dx, dy))) time, which is very fast and effectively a small constant.
 Space Complexity: O(N) to store the slope frequencies in the hash map for any given point.
*/

class Solution {
    func maxPoints(_ points: [[Int]]) -> Int {
        let n = points.count
        if n <= 2 { return n }
        
        var maxTotalPoints = 0
        
        for i in 0..<n {
            var slopeCounts = [String: Int]()
            var maxPointsThroughI = 0
            
            for j in (i + 1)..<n {
                let dx = points[j][0] - points[i][0]
                let dy = points[j][1] - points[i][1]
                
                // Reduce the fraction by their GCD
                let g = gcd(abs(dx), abs(dy))
                
                var reducedDx = dx / g
                var reducedDy = dy / g
                
                // Standardize the sign: if dx is negative, flip both signs 
                // so the negative sign is consistently on dy or dx.
                // Also, if dx is 0, make dy positive to avoid (0, 1) and (0, -1) being different.
                if reducedDx < 0 || (reducedDx == 0 && reducedDy < 0) {
                    reducedDx = -reducedDx
                    reducedDy = -reducedDy
                }
                
                let slopeKey = "\(reducedDy)/\(reducedDx)"
                slopeCounts[slopeKey, default: 0] += 1
                maxPointsThroughI = max(maxPointsThroughI, slopeCounts[slopeKey]!)
            }
            
            // Add 1 for the current point `i` itself
            maxTotalPoints = max(maxTotalPoints, maxPointsThroughI + 1)
        }
        
        return maxTotalPoints
    }
    
    // Helper to calculate Greatest Common Divisor
    private func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
}
