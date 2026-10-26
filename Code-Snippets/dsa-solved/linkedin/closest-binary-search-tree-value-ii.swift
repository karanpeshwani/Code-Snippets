//
//  abc.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 22/10/26.
//

//https://www.geeksforgeeks.org/dsa/find-the-closest-binary-search-tree-value-ii/


import Foundation
// import Collections // Uncomment if you want Heap version below

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
/*
 Approach:
 Problem: Given BST root, target Double and k, find k values closest to target.
 Unique set guaranteed. Answer in any order.
 Optimal Approach (Inorder + Two Pointers) - Uses BST property:
 1. Inorder traversal of BST gives sorted array in ascending order.
 2. Binary search to find insertion index of target (first element >= target).
 3. Set two pointers: l = insertion-1 (predecessor side), r = insertion (successor side).
 4. For k times, compare abs(arr[l] - target) vs abs(arr[r] - target) and pick
    closer one, moving pointer. This is like merging two sorted lists of
    distances.
 Alternative Approach from GFG Article (Max-Heap):
 1. Do any traversal (preorder/inorder).
 2. Maintain a Max-Heap of size k storing (distance = abs(node.val - target), val).
    Max-Heap ordered by distance.
 3. For each node push (distance, val). If heap.count > k, pop max.
 4. At end heap contains k smallest distances.
 Time Complexity:
 - Optimal Inorder+TwoPointers: O(n) for inorder + O(log n) binary search + O(k) selection = O(n)
 - Max-Heap approach: O(n log k) where n = number of nodes, k = required values
 - Stack Predecessor/Successor (best): O(h + k) where h = height of BST, O(log n + k) balanced
 Space Complexity:
 - Inorder+TwoPointers: O(n) for sorted array + O(h) recursion stack
 - Max-Heap: O(k) heap + O(h) recursion stack = O(h + k)
 - Stack approach: O(h + k)
*/
class Solution {
    // MARK: - Optimal Solution - O(n) time, O(n) space
    func closestKValues(_ root: TreeNode?, _ target: Double, _ k: Int) -> [Int] {
        var sorted: [Int] = []
        func inorder(_ node: TreeNode?) {
            guard let node = node else { return }
            inorder(node.left)
            sorted.append(node.val)
            inorder(node.right)
        }
        inorder(root)
        if sorted.count <= k { return sorted }
        // binary search for lower_bound of target
        var lo = 0
        var hi = sorted.count
        while lo < hi {
            let mid = (lo + hi) / 2
            if Double(sorted[mid]) < target {
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        var l = lo - 1
        var r = lo
        var result: [Int] = []
        result.reserveCapacity(k)
        while result.count < k {
            if l < 0 {
                result.append(sorted[r]); r += 1
            } else if r >= sorted.count {
                result.append(sorted[l]); l -= 1
            } else {
                let diffL = abs(Double(sorted[l]) - target)
                let diffR = abs(Double(sorted[r]) - target)
                // <= to keep deterministic, but problem guarantees unique set
                if diffL <= diffR {
                    result.append(sorted[l]); l -= 1
                } else {
                    result.append(sorted[r]); r += 1
                }
            }
        }
        return result
    }
    // MARK: - GFG Max-Heap Solution using swift-collections - O(n log k)
    /*
    func closestKValuesHeap(_ root: TreeNode?, _ target: Double, _ k: Int) -> [Int] {
        import Collections
        var heap = Heap<(dist: Double, val: Int)> { $0.dist > $1.dist } // Max-Heap
        func dfs(_ node: TreeNode?) {
            guard let node = node else { return }
            let d = abs(Double(node.val) - target)
            heap.insert((d, node.val))
            if heap.count > k {
                heap.popMax()
            }
            dfs(node.left)
            dfs(node.right)
        }
        dfs(root)
        return heap.map { $0.val }
    }
    */
}
// Example:
// root = [5,3,6,2,4], target = 3.714286, k = 2 -> [4,3]
// let root = TreeNode(5); root.left = TreeNode(3); root.right = TreeNode(6)
// root.left?.left = TreeNode(2); root.left?.right = TreeNode(4)
// print(Solution().closestKValues(root, 3.714286, 2))
