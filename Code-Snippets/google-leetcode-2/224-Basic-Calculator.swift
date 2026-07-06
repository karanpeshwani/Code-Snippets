// 224. Basic Calculator
// https://leetcode.com/problems/basic-calculator
//
// Intuition/Explanation:
// We can use a stack to keep track of the current running result and the sign just before an open parenthesis.
// We iterate through the string character by character:
// - Digits: Used to build the current multi-digit number.
// - '+' or '-': Adds the current number to the result (multiplied by the current sign), then updates the sign.
// - '(': Pushes the current result and sign onto the stack, and resets them for the upcoming sub-expression.
// - ')': Computes the final value of the sub-expression, multiplies it by the popped sign, and adds it to the popped previous result.
//
// Time Complexity: O(N), where N is the length of the string. We process each character exactly once.
// Space Complexity: O(N) for the stack in the worst case (e.g., deeply nested parentheses).

class Solution {
    func calculate(_ s: String) -> Int {
        var stack = [Int]()
        var currentNumber = 0
        var currentResult = 0
        var sign = 1
        
        let chars = Array(s)
        
        for char in chars {
            if char.isWholeNumber {
                // Build the current number
                currentNumber = currentNumber * 10 + char.wholeNumberValue!
            } else if char == "+" {
                // Add the evaluated number to the result
                currentResult += sign * currentNumber
                // Reset for the next number
                currentNumber = 0
                sign = 1
            } else if char == "-" {
                currentResult += sign * currentNumber
                currentNumber = 0
                sign = -1
            } else if char == "(" {
                // Push the result and sign to stack
                stack.append(currentResult)
                stack.append(sign)
                
                // Reset result and sign for the new sub-expression
                currentResult = 0
                sign = 1
            } else if char == ")" {
                // Evaluate the last number in the sub-expression
                currentResult += sign * currentNumber
                currentNumber = 0
                
                // Pop the sign before the parenthesis and multiply
                currentResult *= stack.removeLast()
                
                // Pop the result before the parenthesis and add
                currentResult += stack.removeLast()
            }
        }
        
        // Add the last number to the result
        if currentNumber != 0 {
            currentResult += sign * currentNumber
        }
        
        return currentResult
    }
}
