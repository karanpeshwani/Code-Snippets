// 465. Optimal Account Balancing
// https://leetcode.com/problems/optimal-account-balancing

/*
 Intuition:
 The problem asks for the minimum number of transactions to settle all debts.
 First, we calculate the net balance of each person. A positive balance means the person
 needs to receive money, and a negative balance means the person owes money.
 People with a net balance of zero are already settled.
 We collect all non-zero balances into an array.
 To find the minimum transactions, we can use backtracking. We try to settle the first person's
 debt with someone else who has the opposite sign in balance. We recursively settle the rest
 and find the minimum path.
 
 Time Complexity: O(N!)
 - In the worst case, we might try all permutations of matching debts.
 - For N non-zero balances, the backtracking state space tree has at most N! leaves.
 - However, pruning (only matching opposite signs) significantly reduces the actual number of branches.

 Space Complexity: O(N)
 - The recursion stack can go up to depth N.
 - The array of non-zero balances takes O(N) space.
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
        
        // Filter out zero balances
        var debt = balances.values.filter { $0 != 0 }
        
        return dfs(0, &debt)
    }
    
    private func dfs(_ start: Int, _ debt: inout [Int]) -> Int {
        // Skip already settled balances
        var curr = start
        while curr < debt.count && debt[curr] == 0 {
            curr += 1
        }
        
        // If all balances are settled, no more transactions needed
        if curr == debt.count {
            return 0
        }
        
        var minTransactions = Int.max
        
        // Try to settle debt[curr] with debt[i]
        for i in (curr + 1)..<debt.count {
            // Only try if they have opposite signs (one owes, one receives)
            if debt[curr] * debt[i] < 0 {
                // Settle debt[curr] with debt[i]
                debt[i] += debt[curr]
                
                minTransactions = min(minTransactions, 1 + dfs(curr + 1, &debt))
                
                // Backtrack
                debt[i] -= debt[curr]
            }
        }
        
        return minTransactions
    }
}
