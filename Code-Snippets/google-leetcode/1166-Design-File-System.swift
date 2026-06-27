// 1166. Design File System
// https://leetcode.com/problems/design-file-system/
//
// Time Complexity: 
//   - createPath: O(L), where L is the length of the path string. We split the string by "/" and traverse the Trie. Dictionary lookup at each level is O(1) on average.
//   - get: O(L), traversing the components of the path similarly takes time proportional to the length of the path.
// Space Complexity: O(N * L), where N is the total number of paths created and L is the average path length. We store all valid paths in a Trie structure.

class FileSystem {
    
    // Node represents a path component in the file system
    class Node {
        var value: Int
        var children: [String: Node] = [:]
        
        init(value: Int) {
            self.value = value
        }
    }
    
    private let root: Node
    
    init() {
        // Root represents the base "/" path which has no value
        root = Node(value: -1)
    }
    
    func createPath(_ path: String, _ value: Int) -> Bool {
        // Remove empty components resulting from the leading slash
        let components = path.split(separator: "/").map { String($0) }
        guard !components.isEmpty else { return false }
        
        var curr = root
        
        // Traverse all the way up to the parent directory
        for i in 0..<components.count - 1 {
            let name = components[i]
            if let next = curr.children[name] {
                curr = next
            } else {
                // Parent path does not exist
                return false
            }
        }
        
        // Check if the final path already exists
        let finalName = components.last!
        if curr.children[finalName] != nil {
            return false
        }
        
        // Create the new path with the given value
        curr.children[finalName] = Node(value: value)
        return true
    }
    
    func get(_ path: String) -> Int {
        let components = path.split(separator: "/").map { String($0) }
        guard !components.isEmpty else { return -1 }
        
        var curr = root
        
        // Traverse the path to find the corresponding value
        for component in components {
            if let next = curr.children[component] {
                curr = next
            } else {
                // Path does not exist
                return -1
            }
        }
        
        return curr.value
    }
}
