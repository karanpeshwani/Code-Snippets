//
//  345.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 23/10/26.
//

//https://www.geeksforgeeks.org/dsa/find-nested-list-weight-sum-ii/

/*
 Approach:
 - The weight of an integer is: maxDepth - depth + 1.
 - First pass: use an explicit stack to find the maximum depth among all integers.
 - Second pass: use another explicit stack to traverse all integers and accumulate:
       value * (maxDepth - depth + 1)
 - Both traversals use DFS with a stack, as requested.

 Time Complexity: O(N)
   - N is the total number of NestedInteger elements (integers + lists).
   - Each element is visited at most twice.

 Space Complexity: O(N)
   - In the worst case, the explicit stack may hold O(N) elements.
*/

class Solution {
    func depthSumInverse(_ nestedList: [NestedInteger]) -> Int {
        guard !nestedList.isEmpty else { return 0 }

        // First pass: find the maximum depth containing an integer.
        var maxDepth = 0
        var stack: [(node: NestedInteger, depth: Int)] =
            nestedList.map { ($0, 1) }

        while let (node, depth) = stack.popLast() {
            if node.isInteger() {
                maxDepth = max(maxDepth, depth)
            } else {
                for child in node.getList() {
                    stack.append((child, depth + 1))
                }
            }
        }

        // Second pass: compute the inverse-depth weighted sum.
        var result = 0
        stack = nestedList.map { ($0, 1) }

        while let (node, depth) = stack.popLast() {
            if node.isInteger() {
                let weight = maxDepth - depth + 1
                result += node.getInteger() * weight
            } else {
                for child in node.getList() {
                    stack.append((child, depth + 1))
                }
            }
        }

        return result
    }
}
