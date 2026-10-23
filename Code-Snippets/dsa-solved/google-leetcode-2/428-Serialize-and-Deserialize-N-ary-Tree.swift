// 428. Serialize and Deserialize N-ary Tree
// https://leetcode.com/problems/serialize-and-deserialize-n-ary-tree

/*
 Intuition:
 To serialize an N-ary tree, we can use a preorder traversal. Unlike a binary tree where we
 can just use a null marker for absent left/right children, an N-ary tree node can have a
 variable number of children.
 We can store the node's value followed by the number of children it has. Then we recursively
 serialize each child.
 Format: "value,num_children,child1,child2,..."
 To deserialize, we read the value and the number of children. We create the node, and then
 recursively read its children for the specified number of times.

 Time Complexity: O(N)
 - Both serialization and deserialization visit each node exactly once.
 - String joining and splitting take O(N) time where N is the total length of the serialized string.

 Space Complexity: O(N)
 - The recursion stack can go as deep as the height of the tree, which is O(N) in the worst case.
 - The serialized string and the array of strings obtained from splitting it take O(N) space.
 - Overall space complexity is O(N).
 */

/**
 * Definition for a Node.
 * public class Node {
 *     public var val: Int
 *     public var children: [Node]
 *     public init(_ val: Int) {
 *         self.val = val
 *         self.children = []
 *     }
 * }
 */

class Codec {
    // Encodes a tree to a single string.
    func serialize(_ root: Node?) -> String {
        var result = [String]()
        
        func dfs(_ node: Node?) {
            guard let node = node else { return }
            result.append(String(node.val))
            result.append(String(node.children.count))
            for child in node.children {
                dfs(child)
            }
        }
        
        dfs(root)
        return result.joined(separator: ",")
    }
    
    // Decodes your encoded data to tree.
    func deserialize(_ data: String) -> Node? {
        if data.isEmpty { return nil }
        
        let values = data.split(separator: ",")
        var index = 0
        
        func buildTree() -> Node? {
            if index >= values.count { return nil }
            
            guard let val = Int(values[index]) else { return nil }
            index += 1
            guard let numChildren = Int(values[index]) else { return nil }
            index += 1
            
            let node = Node(val)
            for _ in 0..<numChildren {
                if let child = buildTree() {
                    node.children.append(child)
                }
            }
            
            return node
        }
        
        return buildTree()
    }
}
