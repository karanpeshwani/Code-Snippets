// 987-Vertical-Order-Traversal-of-a-Binary-Tree.swift
// 987. Vertical Order Traversal of a Binary Tree
// https://leetcode.com/problems/vertical-order-traversal-of-a-binary-tree/
//
// Time Complexity: O(N log N) where N is the number of nodes. We traverse all nodes in O(N), but then sort the elements based on column, row and value.
// Space Complexity: O(N) to store the mapping from col and row to node values.

// Definition for a binary tree node.
// public class TreeNode {
//     public var val: Int
//     public var left: TreeNode?
//     public var right: TreeNode?
//     public init() { self.val = 0; self.left = nil; self.right = nil; }
//     public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
//     public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
//         self.val = val
//         self.left = left
//         self.right = right
//     }
// }

class Solution {
    func verticalTraversal(_ root: TreeNode?) -> [[Int]] {
        var nodes = [(col: Int, row: Int, val: Int)]()
        
        func dfs(_ node: TreeNode?, _ col: Int, _ row: Int) {
            guard let node = node else { return }
            nodes.append((col, row, node.val))
            dfs(node.left, col - 1, row + 1)
            dfs(node.right, col + 1, row + 1)
        }
        
        dfs(root, 0, 0)
        
        // Sort by column, then row, then value
        nodes.sort {
            if $0.col != $1.col { return $0.col < $1.col }
            if $0.row != $1.row { return $0.row < $1.row }
            return $0.val < $1.val
        }
        
        var res = [[Int]]()
        var lastCol = Int.min
        var currColList = [Int]()
        
        for node in nodes {
            if node.col != lastCol {
                if !currColList.isEmpty {
                    res.append(currColList)
                    currColList = []
                }
                lastCol = node.col
            }
            currColList.append(node.val)
        }
        
        if !currColList.isEmpty {
            res.append(currColList)
        }
        
        return res
    }
}
