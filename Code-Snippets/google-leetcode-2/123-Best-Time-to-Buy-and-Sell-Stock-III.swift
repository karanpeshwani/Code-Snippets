// 123. Best Time to Buy and Sell Stock III
// https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii
//
// Intuition/Explanation:
// We can use dynamic programming or a state machine approach. Since we are allowed at most two transactions, 
// on any given day we can be in one of four states regarding our transactions:
// 1. `buy1`: Max profit after first buy. We want to maximize this: `max(buy1, -price)`.
// 2. `sell1`: Max profit after first sell. We want to maximize this: `max(sell1, buy1 + price)`.
// 3. `buy2`: Max profit after second buy. We want to maximize this: `max(buy2, sell1 - price)`.
// 4. `sell2`: Max profit after second sell. We want to maximize this: `max(sell2, buy2 + price)`.
// We iterate through the prices and update these four variables.
//
// Time Complexity: O(N), where N is the number of prices. We iterate through the array exactly once.
// Space Complexity: O(1), as we only use four integer variables to keep track of the max profits.

class Solution {
    func maxProfit(_ prices: [Int]) -> Int {
        var buy1 = Int.min
        var sell1 = 0
        var buy2 = Int.min
        var sell2 = 0
        
        for price in prices {
            // Update the states
            // Note: The order doesn't strictly matter if we consider them conceptually happening sequentially.
            // Using the current day's price to update all states is valid.
            buy1 = max(buy1, -price)
            sell1 = max(sell1, buy1 + price)
            buy2 = max(buy2, sell1 - price)
            sell2 = max(sell2, buy2 + price)
        }
        
        return sell2
    }
}
