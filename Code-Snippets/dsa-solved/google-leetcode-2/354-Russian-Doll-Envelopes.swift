// 354. Russian Doll Envelopes
// https://leetcode.com/problems/russian-doll-envelopes

/*
 Intuition:
 The problem asks for the maximum number of envelopes that can be nested.
 This is similar to the Longest Increasing Subsequence (LIS) problem.
 To apply LIS, we can sort the envelopes based on width in ascending order.
 However, if envelopes have the same width, they cannot fit into one another.
 So, for envelopes with the same width, we sort them by height in descending order.
 By doing this, when we look for strictly increasing heights, the descending order
 of heights for the same width ensures we only pick at most one envelope of that width.
 Then, the problem reduces to finding the LIS on the heights.

 Time Complexity: O(N log N)
 - Sorting the envelopes takes O(N log N) time, where N is the number of envelopes.
 - Finding the LIS using binary search takes O(N log N) time.
 - Overall time complexity is O(N log N).

 Space Complexity: O(N)
 - We use an array `dp` of size up to N to store the LIS.
 - The space complexity for sorting might also take O(N) depending on the algorithm.
 - Overall space complexity is O(N).
 */

class Solution {
    func maxEnvelopes(_ envelopes: [[Int]]) -> Int {
        // Sort envelopes: ascending by width, descending by height if widths are equal
        let sortedEnvelopes = envelopes.sorted {
            if $0[0] == $1[0] {
                return $0[1] > $1[1]
            }
            return $0[0] < $1[0]
        }
        
        var dp = [Int]() // dp array to store the heights for LIS
        
        for envelope in sortedEnvelopes {
            let height = envelope[1]
            
            // Binary search to find the correct position for current height
            var left = 0
            var right = dp.count
            
            while left < right {
                let mid = left + (right - left) / 2
                if dp[mid] < height {
                    left = mid + 1
                } else {
                    right = mid
                }
            }
            
            // If the height is greater than all elements in dp, append it
            if left == dp.count {
                dp.append(height)
            } else {
                // Otherwise, replace the element to keep values as small as possible
                dp[left] = height
            }
        }
        
        return dp.count
    }
}
