// 124. Binary Tree Maximum Path Sum
// https://leetcode.com/problems/binary-tree-maximum-path-sum/
//
// Time Complexity: O(N), where N is the number of nodes in the binary tree. We visit each node exactly once during our post-order traversal to compute the maximum gain from each subtree.
// Space Complexity: O(H), where H is the height of the tree. This space is used by the recursion call stack. In the worst case (skewed tree), H = N, leading to O(N) space. For a perfectly balanced tree, H = log(N).

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     public var val: Int
 *     public var left: TreeNode?
 *     public var right: TreeNode?
 *     public init() { self.val = 0; self.left = nil; self.right = nil; }
 *     public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
 *     public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
 *         self.val = val
 *         self.left = left
 *         self.right = right
 *     }
 * }
 */

class Solution {
    func maxPathSum(_ root: TreeNode?) -> Int {
        // Initialize with minimum possible value
        var maxSum = Int.min
        
        // Post-order traversal to calculate the max path sum from leaves to the root
        func dfs(_ node: TreeNode?) -> Int {
            guard let node = node else { return 0 }
            
            // Recursively calculate the maximum path sum of the left and right subtrees.
            // If the max path sum of a subtree is negative, we ignore it by taking max with 0,
            // meaning we choose not to include that subtree in our path.
            let leftGain = max(dfs(node.left), 0)
            let rightGain = max(dfs(node.right), 0)
            
            // The path maximum for the current node as the highest point (root of the path).
            // It includes the node's value and both the positive left and right gains.
            let currentPathSum = node.val + leftGain + rightGain
            
            // Update the global maximum path sum if the current path is greater
            maxSum = max(maxSum, currentPathSum)
            
            // For the recursive return, we can only continue the path through one of the children.
            // So we return the node's value plus the max of left or right gains.
            return node.val + max(leftGain, rightGain)
        }
        
        dfs(root)
        return maxSum
    }
}
