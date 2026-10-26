//
//  abc.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 23/10/26.
//
//https://leetcode.com/problems/find-leaves-of-binary-tree/description/

/*
 Approach:
 We can solve this problem optimally using a Depth First Search (DFS) with Post-order Traversal.
 The core idea is to group nodes by their "height" from the bottom of the tree.
 - Leaf nodes (which are removed first) have a height of 0.
 - The parent of leaf nodes will have a height of 1, and so on.
 - The height of any given node can be defined as: `max(height(node.left), height(node.right)) + 1`.
 
 Nodes that share the same height are removed at the exact same iteration. We can maintain a 2D array `result`, where the index corresponds to the node's height. As we compute the height of each node during our bottom-up traversal, we simply place the node's value into `result[height]`.
 
 Time Complexity:
 O(N), where N is the total number of nodes in the binary tree. We visit each node exactly once during our DFS traversal, and the work done at each node (finding max, appending to array) takes O(1) time.
 
 Space Complexity:
 O(N) overall.
 - The output array `result` will contain all N elements, which takes O(N) space.
 - The recursive call stack will take O(H) space, where H is the height of the tree. In the worst-case scenario (a completely skewed tree), H = N, which takes O(N) space. In a perfectly balanced tree, H = log(N).
*/

// Definition for a binary tree node.
public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    public init() { self.val = 0; self.left = nil; self.right = nil; }
    public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
    public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
        self.val = val
        self.left = left
        self.right = right
    }
}

class Solution {
    func findLeaves(_ root: TreeNode?) -> [[Int]] {
        var result: [[Int]] = []
        
        // Helper function to perform DFS and return the height of the node
        @discardableResult
        func dfs(_ node: TreeNode?) -> Int {
            guard let node = node else {
                return -1 // Base case: null nodes have a height of -1
            }
            
            let leftHeight = dfs(node.left)
            let rightHeight = dfs(node.right)
            
            // Current node's height is 1 plus the maximum height of its children
            let currentHeight = max(leftHeight, rightHeight) + 1
            
            // If this is the first time we've seen this height, add a new array
            if result.count == currentHeight {
                result.append([])
            }
            
            // Group the node's value by its height
            result[currentHeight].append(node.val)
            
            return currentHeight
        }
        
        dfs(root)
        
        return result
    }
}
