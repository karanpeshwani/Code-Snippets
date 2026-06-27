// 2458. Height of Binary Tree After Subtree Removal Queries
// https://leetcode.com/problems/height-of-binary-tree-after-subtree-removal-queries
//
// Time Complexity: O(N + M)
//   - N is the number of nodes in the tree, and M is the number of queries.
//   - We perform a single DFS traversal to compute the depths and heights of all nodes, taking O(N) time.
//   - We answer each of the M queries in O(1) time using precomputed max heights, taking O(M) time.
//   - Overall time complexity is O(N + M).
// Space Complexity: O(N)
//   - We store depth, max height, and second max height for up to N levels.
//   - Using fixed-size arrays based on max constraints ensures O(N) space and optimal performance.
//   - The recursive DFS stack takes up to O(N) space in the worst case for a skewed tree.

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
    func treeQueries(_ root: TreeNode?, _ queries: [Int]) -> [Int] {
        // Since n <= 10^5, we can use arrays indexed by node values/depths for fast access.
        let maxNodes = 100005
        var depths = Array(repeating: 0, count: maxNodes)
        var depthMax1 = Array(repeating: -1, count: maxNodes)
        var depthMax2 = Array(repeating: -1, count: maxNodes)
        var depthMax1Node = Array(repeating: -1, count: maxNodes)
        
        // DFS returns the height of the node (longest path to a leaf, leaf height = 0)
        func dfs(_ node: TreeNode?, _ d: Int) -> Int {
            guard let node = node else { return -1 }
            
            // Record depth of current node
            depths[node.val] = d
            
            // Compute height recursively
            let h = max(dfs(node.left, d + 1), dfs(node.right, d + 1)) + 1
            
            // Maintain top 2 maximum heights for the current depth
            if h > depthMax1[d] {
                depthMax2[d] = depthMax1[d]
                depthMax1[d] = h
                depthMax1Node[d] = node.val
            } else if h > depthMax2[d] {
                depthMax2[d] = h
            }
            
            return h
        }
        
        // Precompute all values
        _ = dfs(root, 0)
        
        var ans = [Int]()
        ans.reserveCapacity(queries.count)
        
        // Answer each query in O(1) time
        for q in queries {
            let d = depths[q]
            // If the query node is the one providing the maximum height for its depth,
            // removing it means the max depth achievable through other nodes at this depth
            // falls back to the second maximum height (depthMax2).
            if depthMax1Node[d] == q {
                ans.append(d + depthMax2[d])
            } else {
                ans.append(d + depthMax1[d])
            }
        }
        
        return ans
    }
}
