// 465. Optimal Account Balancing
// https://leetcode.com/problems/optimal-account-balancing/

/*
 Intuition:
 The problem asks for the minimum number of transactions to settle all debts.
 First, we calculate the net balance for each person. A person with a 0 balance is already settled.
 We only care about the people with non-zero balances. The problem then reduces to matching 
 negative balances (debtors) with positive balances (creditors).
 We can use DFS with backtracking to try all possible settlements.
 For a person at index `idx` with a non-zero balance, we try to settle their balance by transferring 
 it to another person at index `i` (where `i > idx`) who has a balance of the opposite sign.
 To optimize:
 - If the balance at `idx` is 0, we move to `idx + 1`.
 - If we find a person `i` whose balance exactly cancels out `idx`'s balance (`balance[i] + balance[idx] == 0`), 
   we can greedily match them and break out of the loop.

 Time Complexity: O(N!)
 - In the worst case, we might try to match each person with all remaining people. 
 - N is the number of people with non-zero balances (usually small, N <= 12 to 21).
 - Total time complexity is O(N!), though pruning makes it much faster in practice.

 Space Complexity: O(N)
 - We use an array of size N to store the non-zero balances.
 - The recursion depth is at most N.
 - Overall space complexity is O(N).
 */

class Solution {
    func minTransfers(_ transactions: [[Int]]) -> Int {
        var balances = [Int: Int]()
        
        // Calculate net balance for each person
        for transaction in transactions {
            let from = transaction[0]
            let to = transaction[1]
            let amount = transaction[2]
            
            balances[from, default: 0] -= amount
            balances[to, default: 0] += amount
        }
        
        // Extract only non-zero balances
        var debt = balances.values.filter { $0 != 0 }
        
        // DFS function to find minimum transactions
        func dfs(_ idx: Int) -> Int {
            // Find the next person with a non-zero balance
            var curr = idx
            while curr < debt.count && debt[curr] == 0 {
                curr += 1
            }
            
            // If all balances are settled, 0 transactions needed
            if curr == debt.count {
                return 0
            }
            
            var minT = Int.max
            
            // Try settling curr's balance with someone later in the array
            for i in (curr + 1)..<debt.count {
                // If they have opposite signs (one owes, one is owed)
                if debt[curr] * debt[i] < 0 {
                    // Transfer the balance
                    debt[i] += debt[curr]
                    
                    // Recursively solve for the rest
                    minT = min(minT, 1 + dfs(curr + 1))
                    
                    // Backtrack
                    debt[i] -= debt[curr]
                    
                    // Optimization: if we found a perfect match, no need to look further
                    if debt[curr] + debt[i] == 0 {
                        break
                    }
                }
            }
            
            return minT
        }
        
        return dfs(0)
    }
}
