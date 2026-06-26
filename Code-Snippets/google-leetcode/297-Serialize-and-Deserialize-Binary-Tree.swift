// 297. Serialize and Deserialize Binary Tree
// Link: https://leetcode.com/problems/serialize-and-deserialize-binary-tree/
//
// Time Complexity: O(N), where N is the number of nodes in the tree.
// Explanation: Both serialization and deserialization visit each node exactly once using a preorder traversal.
// Space Complexity: O(N)
// Explanation: The string representation and the array created during deserialization take O(N) space. The recursion stack also takes up to O(N) in the worst case (skewed tree).

// Definition for a binary tree node.
public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    public init(_ val: Int) {
        self.val = val
        self.left = nil
        self.right = nil
    }
}

class Codec {
    // Encodes a tree to a single string.
    func serialize(_ root: TreeNode?) -> String {
        var result = [String]()
        
        func dfs(_ node: TreeNode?) {
            guard let node = node else {
                result.append("null")
                return
            }
            result.append(String(node.val))
            dfs(node.left)
            dfs(node.right)
        }
        
        dfs(root)
        return result.joined(separator: ",")
    }
    
    // Decodes your encoded data to tree.
    func deserialize(_ data: String) -> TreeNode? {
        var nodes = data.split(separator: ",").map { String($0) }
        var index = 0
        
        func dfs() -> TreeNode? {
            if index >= nodes.count { return nil }
            
            let valStr = nodes[index]
            index += 1
            
            if valStr == "null" {
                return nil
            }
            
            let node = TreeNode(Int(valStr)!)
            node.left = dfs()
            node.right = dfs()
            return node
        }
        
        return dfs()
    }
}
