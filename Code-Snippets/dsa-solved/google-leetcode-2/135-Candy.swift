// 135. Candy
// https://leetcode.com/problems/candy

/*
 Intuition/Explanation:
 We can solve this using a two-pass greedy approach. Initially, we give every child 1 candy.
 Left-to-Right Pass: We traverse from left to right. If a child has a higher rating than their left neighbor, 
 they must get more candies than the left neighbor. So we set their candies to `left_neighbor_candies + 1`.
 Right-to-Left Pass: We traverse from right to left. If a child has a higher rating than their right neighbor, 
 their candy count must be strictly greater than the right neighbor's candy count. 
 We update their candies to `max(current candies, right_neighbor_candies + 1)`.
 The total sum of candies at the end is the minimum candies required.

 Time Complexity: O(N), where N is the number of children. We make exactly two passes over the ratings array.
 Space Complexity: O(N) to store the candy count for each child in a separate array.
*/

class Solution {
    func candy(_ ratings: [Int]) -> Int {
        let n = ratings.count
        if n == 0 { return 0 }
        
        // Give everyone at least one candy
        var candies = Array(repeating: 1, count: n)
        
        // Left-to-right pass
        for i in 1..<n {
            if ratings[i] > ratings[i - 1] {
                candies[i] = candies[i - 1] + 1
            }
        }
        
        // Right-to-left pass
        for i in (0..<n - 1).reversed() {
            if ratings[i] > ratings[i + 1] {
                candies[i] = max(candies[i], candies[i + 1] + 1)
            }
        }
        
        // Sum up total candies
        var totalCandies = 0
        for candy in candies {
            totalCandies += candy
        }
        
        return totalCandies
    }
}
