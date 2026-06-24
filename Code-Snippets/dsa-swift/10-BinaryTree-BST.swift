//
//  10-BinaryTree-BST.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - TreeNode

final class TreeNode<T: Comparable> {
    var val:   T
    var left:  TreeNode<T>?
    var right: TreeNode<T>?

    init(_ val: T, _ left: TreeNode<T>? = nil, _ right: TreeNode<T>? = nil) {
        self.val   = val
        self.left  = left
        self.right = right
    }
}

// LeetCode uses: public class TreeNode { var val: Int; var left: TreeNode?; var right: TreeNode? }

// MARK: - BST: Insert   O(log n) average, O(n) worst

func bstInsert(_ root: TreeNode<Int>?, _ val: Int) -> TreeNode<Int> {
    guard let node = root else { return TreeNode(val) }
    if val < node.val      { node.left  = bstInsert(node.left,  val) }
    else if val > node.val { node.right = bstInsert(node.right, val) }
    return node
}

// MARK: - BST: Search   O(log n) average

func bstSearch(_ root: TreeNode<Int>?, _ val: Int) -> TreeNode<Int>? {
    guard let node = root else { return nil }
    if val == node.val       { return node }
    else if val < node.val   { return bstSearch(node.left,  val) }
    else                     { return bstSearch(node.right, val) }
}

// MARK: - BST: Delete   O(log n) average

func bstDelete(_ root: TreeNode<Int>?, _ val: Int) -> TreeNode<Int>? {
    guard let node = root else { return nil }
    if val < node.val {
        node.left  = bstDelete(node.left,  val)
    } else if val > node.val {
        node.right = bstDelete(node.right, val)
    } else {
        // Node to delete found
        if node.left == nil  { return node.right }
        if node.right == nil { return node.left  }
        // Node has two children: replace with inorder successor (min of right subtree)
        let successor = findMin(node.right)!
        node.val   = successor.val
        node.right = bstDelete(node.right, successor.val)
    }
    return node
}

func findMin(_ root: TreeNode<Int>?) -> TreeNode<Int>? {
    var cur = root
    while let left = cur?.left { cur = left }
    return cur
}

func findMax(_ root: TreeNode<Int>?) -> TreeNode<Int>? {
    var cur = root
    while let right = cur?.right { cur = right }
    return cur
}

// MARK: - DFS Traversals — Recursive

// Inorder  Left → Root → Right   (gives sorted output for BST)
func inorder<T>(_ root: TreeNode<T>?) -> [T] {
    guard let node = root else { return [] }
    return inorder(node.left) + [node.val] + inorder(node.right)
}

// Preorder  Root → Left → Right   (useful for serialisation / clone)
func preorder<T>(_ root: TreeNode<T>?) -> [T] {
    guard let node = root else { return [] }
    return [node.val] + preorder(node.left) + preorder(node.right)
}

// Postorder  Left → Right → Root   (useful for deletion / size)
func postorder<T>(_ root: TreeNode<T>?) -> [T] {
    guard let node = root else { return [] }
    return postorder(node.left) + postorder(node.right) + [node.val]
}

// MARK: - DFS Traversals — Iterative (no recursion stack overhead)

// Iterative Inorder
func inorderIterative(_ root: TreeNode<Int>?) -> [Int] {
    var result = [Int](), stack = [TreeNode<Int>]()
    var cur = root
    while cur != nil || !stack.isEmpty {
        while let node = cur { stack.append(node); cur = node.left }
        let node = stack.removeLast()
        result.append(node.val)
        cur = node.right
    }
    return result
}

// Iterative Preorder
func preorderIterative(_ root: TreeNode<Int>?) -> [Int] {
    guard let root = root else { return [] }
    var result = [Int](), stack = [root]
    while !stack.isEmpty {
        let node = stack.removeLast()
        result.append(node.val)
        if let right = node.right { stack.append(right) }
        if let left  = node.left  { stack.append(left)  }
    }
    return result
}

// Iterative Postorder  (reverse of modified preorder)
func postorderIterative(_ root: TreeNode<Int>?) -> [Int] {
    guard let root = root else { return [] }
    var result = [Int](), stack = [root]
    while !stack.isEmpty {
        let node = stack.removeLast()
        result.append(node.val)
        if let left  = node.left  { stack.append(left)  }
        if let right = node.right { stack.append(right) }
    }
    return result.reversed()
}

// MARK: - BFS — Level Order   O(n)

func levelOrder(_ root: TreeNode<Int>?) -> [[Int]] {
    guard let root = root else { return [] }
    var result = [[Int]](), queue = [root]
    while !queue.isEmpty {
        let size = queue.count
        var level = [Int]()
        for _ in 0..<size {
            let node = queue.removeFirst()   // use Deque in practice
            level.append(node.val)
            if let l = node.left  { queue.append(l) }
            if let r = node.right { queue.append(r) }
        }
        result.append(level)
    }
    return result
}

// Zigzag Level Order (alternate L→R and R→L)
func zigzagLevelOrder(_ root: TreeNode<Int>?) -> [[Int]] {
    guard let root = root else { return [] }
    var result = [[Int]](), queue = [root], leftToRight = true
    while !queue.isEmpty {
        let size = queue.count
        var level = [Int]()
        for _ in 0..<size {
            let node = queue.removeFirst()
            level.append(node.val)
            if let l = node.left  { queue.append(l) }
            if let r = node.right { queue.append(r) }
        }
        result.append(leftToRight ? level : level.reversed())
        leftToRight.toggle()
    }
    return result
}

// MARK: - Tree Properties

// Height (max depth from root to leaf)   O(n)
func height<T>(_ root: TreeNode<T>?) -> Int {
    guard let node = root else { return 0 }
    return 1 + max(height(node.left), height(node.right))
}

// Depth of a node   O(n)
func depth<T>(_ root: TreeNode<T>?, _ target: T, _ currentDepth: Int = 0) -> Int {
    guard let node = root else { return -1 }
    if node.val == target { return currentDepth }
    let left  = depth(node.left,  target, currentDepth + 1)
    if left  != -1 { return left }
    return depth(node.right, target, currentDepth + 1)
}

// Is Balanced: no two subtree heights differ by more than 1   O(n)
func isBalanced<T>(_ root: TreeNode<T>?) -> Bool {
    func check(_ node: TreeNode<T>?) -> Int {
        guard let n = node else { return 0 }
        let l = check(n.left);  if l == -1 { return -1 }
        let r = check(n.right); if r == -1 { return -1 }
        return abs(l - r) <= 1 ? max(l, r) + 1 : -1
    }
    return check(root) != -1
}

// Diameter: longest path between any two nodes (may not pass root)   O(n)
func diameterOfBinaryTree(_ root: TreeNode<Int>?) -> Int {
    var maxDiameter = 0
    func dfs(_ node: TreeNode<Int>?) -> Int {
        guard let n = node else { return 0 }
        let l = dfs(n.left), r = dfs(n.right)
        maxDiameter = max(maxDiameter, l + r)
        return max(l, r) + 1
    }
    dfs(root)
    return maxDiameter
}

// MARK: - Validate BST   O(n)

func isValidBST(_ root: TreeNode<Int>?) -> Bool {
    func validate(_ node: TreeNode<Int>?, _ min: Int, _ max: Int) -> Bool {
        guard let n = node else { return true }
        if n.val <= min || n.val >= max { return false }
        return validate(n.left, min, n.val) && validate(n.right, n.val, max)
    }
    return validate(root, Int.min, Int.max)
}

// MARK: - Lowest Common Ancestor (LCA)   O(n)

// LCA in Binary Tree (not BST)
func lcaBinaryTree(_ root: TreeNode<Int>?, _ p: Int, _ q: Int) -> TreeNode<Int>? {
    guard let node = root else { return nil }
    if node.val == p || node.val == q { return node }
    let left  = lcaBinaryTree(node.left,  p, q)
    let right = lcaBinaryTree(node.right, p, q)
    if left != nil && right != nil { return node }   // p and q are in different subtrees
    return left ?? right
}

// LCA in BST  O(log n) average
func lcaBST(_ root: TreeNode<Int>?, _ p: Int, _ q: Int) -> TreeNode<Int>? {
    guard let node = root else { return nil }
    if p < node.val && q < node.val { return lcaBST(node.left,  p, q) }
    if p > node.val && q > node.val { return lcaBST(node.right, p, q) }
    return node   // split point = LCA
}

// MARK: - Path Sum

// Does a root-to-leaf path with given sum exist?
func hasPathSum(_ root: TreeNode<Int>?, _ target: Int) -> Bool {
    guard let node = root else { return false }
    let remaining = target - node.val
    if node.left == nil && node.right == nil { return remaining == 0 }
    return hasPathSum(node.left, remaining) || hasPathSum(node.right, remaining)
}

// All root-to-leaf paths with given sum
func pathSumAll(_ root: TreeNode<Int>?, _ target: Int) -> [[Int]] {
    var results = [[Int]]()
    func dfs(_ node: TreeNode<Int>?, _ remaining: Int, _ path: inout [Int]) {
        guard let n = node else { return }
        path.append(n.val)
        if n.left == nil && n.right == nil && remaining == n.val {
            results.append(path)
        } else {
            dfs(n.left,  remaining - n.val, &path)
            dfs(n.right, remaining - n.val, &path)
        }
        path.removeLast()   // backtrack
    }
    var path = [Int]()
    dfs(root, target, &path)
    return results
}

// MARK: - Serialize / Deserialize   O(n)

func serialize(_ root: TreeNode<Int>?) -> String {
    var parts = [String]()
    func dfs(_ node: TreeNode<Int>?) {
        guard let n = node else { parts.append("#"); return }
        parts.append(String(n.val))
        dfs(n.left); dfs(n.right)
    }
    dfs(root)
    return parts.joined(separator: ",")
}

func deserialize(_ data: String) -> TreeNode<Int>? {
    var parts = data.split(separator: ",").map(String.init)
    var idx = 0
    func build() -> TreeNode<Int>? {
        guard idx < parts.count else { return nil }
        let s = parts[idx]; idx += 1
        if s == "#" { return nil }
        let node = TreeNode(Int(s)!)
        node.left  = build()
        node.right = build()
        return node
    }
    return build()
}

// MARK: - Invert Binary Tree   O(n)

func invertTree<T>(_ root: TreeNode<T>?) -> TreeNode<T>? {
    guard let node = root else { return nil }
    let tmp    = node.left
    node.left  = invertTree(node.right)
    node.right = invertTree(tmp)
    return node
}

// MARK: - Max Path Sum (any path in tree)   O(n)

func maxPathSum(_ root: TreeNode<Int>?) -> Int {
    var globalMax = Int.min
    @discardableResult
    func dfs(_ node: TreeNode<Int>?) -> Int {
        guard let n = node else { return 0 }
        let l = max(0, dfs(n.left))
        let r = max(0, dfs(n.right))
        globalMax = max(globalMax, l + r + n.val)
        return max(l, r) + n.val
    }
    dfs(root)
    return globalMax
}
