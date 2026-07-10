// 1499. Max Value of Equation
// https://leetcode.com/problems/max-value-of-equation/

/*
 Intuition:
 We need to maximize `yi + yj + |xi - xj|` where `|xi - xj| <= k` and `i < j`.
 Since `points` are sorted by `x`, for `i < j`, `xi < xj`, so `|xi - xj| = xj - xi`.
 The equation becomes `yi + yj + xj - xi`, which can be rewritten as `(yi - xi) + (yj + xj)`.
 For a fixed `j`, `yj + xj` is constant. So we want to maximize `(yi - xi)` for `i < j` such that `xj - xi <= k`.
 We can use a monotonic deque or a max-heap to keep track of `(yi - xi)`.
 A sliding window approach with a monotonic deque is optimal. The deque stores indices `i` in decreasing order of `(yi - xi)`.
 We iterate through `points` as `j`. We remove elements from the front of the deque if `xj - xi > k`.
 The front of the deque will then give the maximum `(yi - xi)`. We update the maximum equation value.
 Then we maintain the deque's monotonic property by removing elements from the back that have a smaller or equal `(yi - xi)`.

 Time Complexity: O(N)
 - N is the number of points.
 - Each point is added to and removed from the deque at most once.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - The deque can store at most N elements in the worst case.
 - Overall space complexity is O(N).
 */

import Collections

class Solution {
    func findMaxValueOfEquation(_ points: [[Int]], _ k: Int) -> Int {
        var deque = Deque<Int>() // Stores indices of points
        var maxVal = Int.min
        
        for j in 0..<points.count {
            let xj = points[j][0]
            let yj = points[j][1]
            
            // Remove points from the front that are outside the window `k`
            while let first = deque.first, xj - points[first][0] > k {
                deque.popFirst()
            }
            
            // The front of the deque has the maximum (yi - xi)
            if let first = deque.first {
                let xi = points[first][0]
                let yi = points[first][1]
                maxVal = max(maxVal, yi - xi + yj + xj)
            }
            
            // Maintain monotonic decreasing order of (yi - xi) in the deque
            let currentDiff = yj - xj
            while let last = deque.last, points[last][1] - points[last][0] <= currentDiff {
                deque.popLast()
            }
            
            deque.append(j)
        }
        
        return maxVal
    }
}
