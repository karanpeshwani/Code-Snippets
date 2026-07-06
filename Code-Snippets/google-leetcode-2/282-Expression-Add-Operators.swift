// 282. Expression Add Operators
// https://leetcode.com/problems/expression-add-operators
//
// Intuition/Explanation:
// We use backtracking to generate all possible expressions.
// At each step, we can pick a substring of numbers starting from the current index to form an operand.
// We then recursively try adding '+', '-', or '*' before this operand.
// To handle the precedence of '*', we need to keep track of the value of the last operand added or subtracted.
// If we choose '*', we subtract the previous operand's value from the current running total, 
// and add `previous * current_operand`.
// We must also avoid operands with leading zeros (e.g., "05" is invalid, but "0" alone is valid).
//
// Time Complexity: O(4^N), where N is the length of the string. At each character, we have 4 choices:
// extend the current number, add '+', add '-', or add '*'.
// Space Complexity: O(N) for the recursion stack and the string being built.

class Solution {
    func addOperators(_ num: String, _ target: Int) -> [String] {
        var results = [String]()
        let chars = Array(num)
        
        func backtrack(_ index: Int, _ currentExpr: String, _ currentValue: Int, _ previousValue: Int) {
            // Base case: Reached the end of the string
            if index == chars.count {
                if currentValue == target {
                    results.append(currentExpr)
                }
                return
            }
            
            var currentOperandStr = ""
            var currentOperandVal = 0
            
            for i in index..<chars.count {
                // Leading zero check
                if i != index && chars[index] == "0" {
                    break
                }
                
                currentOperandStr.append(chars[i])
                currentOperandVal = currentOperandVal * 10 + chars[i].wholeNumberValue!
                
                if index == 0 {
                    // First number, no operator before it
                    backtrack(i + 1, currentOperandStr, currentOperandVal, currentOperandVal)
                } else {
                    // Addition
                    backtrack(i + 1, currentExpr + "+" + currentOperandStr, currentValue + currentOperandVal, currentOperandVal)
                    
                    // Subtraction
                    backtrack(i + 1, currentExpr + "-" + currentOperandStr, currentValue - currentOperandVal, -currentOperandVal)
                    
                    // Multiplication (handle precedence by undoing previous operation)
                    let updatedValue = currentValue - previousValue + (previousValue * currentOperandVal)
                    backtrack(i + 1, currentExpr + "*" + currentOperandStr, updatedValue, previousValue * currentOperandVal)
                }
            }
        }
        
        backtrack(0, "", 0, 0)
        return results
    }
}
