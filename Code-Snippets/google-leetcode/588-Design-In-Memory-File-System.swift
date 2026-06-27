// 588. Design In-Memory File System
// https://leetcode.com/problems/design-in-memory-file-system/
//
// Time Complexity: 
//   - ls: O(L + K log K), where L is the path length and K is the number of items in the directory (sorting takes K log K).
//   - mkdir: O(L), where L is the length of the path. We split the path and traverse/create nodes.
//   - addContentToFile: O(L + C), where L is the path length and C is the length of the content being appended.
//   - readContentFromFile: O(L + C), where L is the path length and C is the content length to be returned.
// Space Complexity: O(N * (L + C)) in the worst case, where N is the total number of files/directories, L is the average name length, and C is the average content length.

class FileSystem {
    
    // Node represents either a file or a directory in our file system
    class Node {
        var isFile: Bool = false
        var content: String = ""
        var children: [String: Node] = [:]
    }
    
    private let root: Node
    
    init() {
        root = Node()
    }
    
    // Helper function to traverse the file system trie based on path components
    private func traverse(_ path: String) -> Node {
        var curr = root
        // We avoid empty components which come from spliting paths like "/a/b/c"
        let components = path.split(separator: "/").filter { !$0.isEmpty }
        
        for component in components {
            let name = String(component)
            if curr.children[name] == nil {
                curr.children[name] = Node()
            }
            curr = curr.children[name]!
        }
        return curr
    }
    
    func ls(_ path: String) -> [String] {
        let node = traverse(path)
        
        // If it's a file, just return its name
        if node.isFile {
            let components = path.split(separator: "/")
            return [String(components.last!)]
        }
        
        // If it's a directory, return sorted list of files and directories
        return node.children.keys.sorted()
    }
    
    func mkdir(_ path: String) {
        _ = traverse(path)
    }
    
    func addContentToFile(_ filePath: String, _ content: String) {
        let node = traverse(filePath)
        node.isFile = true
        node.content += content
    }
    
    func readContentFromFile(_ filePath: String) -> String {
        let node = traverse(filePath)
        return node.content
    }
}
