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

private class TreeNodeWrapper {
    let x: Int
    let y: Int
    let treeNode: TreeNode

    init(_ treeNode: TreeNode, _ x: Int, _ y: Int) {
        self.x = x
        self.y = y
        self.treeNode = treeNode
    }
}

class Solution {

    private var columnNodes: [[TreeNodeWrapper]] = Array(repeating: [], count: 2000)

    func verticalTraversal(_ root: TreeNode?) -> [[Int]] {
        var q: Deque<TreeNodeWrapper> = Deque()
        q.append(TreeNodeWrapper(root!, 0, 0))

        while !q.isEmpty {
            let top = q.removeFirst()
            let col = top.x + 1000

            columnNodes[col].append(top)

            if let leftChild = top.treeNode.left {
                q.append(TreeNodeWrapper(leftChild, top.x - 1, top.y + 1))
            }
            if let rightChild = top.treeNode.right {
                q.append(TreeNodeWrapper(rightChild, top.x + 1, top.y + 1))
            }
        }

        var result: [[Int]] = []

        for columnArray in columnNodes {
            if !columnArray.isEmpty {
                let temp = columnArray.sorted {
                    if $0.y == $1.y {
                        return $0.treeNode.val < $1.treeNode.val
                    }
                    return $0.y < $1.y
                }.map {
                    $0.treeNode.val
                }
                result.append(temp)
            }
        }

        return result
    }
}
