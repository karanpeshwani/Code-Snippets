// 307. Range Sum Query - Mutable
// https://leetcode.com/problems/range-sum-query-mutable

/*
 Intuition:
 We need a data structure that can efficiently perform point updates and range queries on an array.
 A Segment Tree is perfect for this. It recursively divides the array into segments (halves)
 and stores the sum of each segment in a tree node.
 - `build`: Recursively divides the array until the segment size is 1 (a single element), and
   then builds the tree from the bottom up by summing the children.
 - `update`: Recursively traverses the tree to find the leaf node corresponding to the index,
   updates its value, and then updates the sums of its ancestors on the way back up.
 - `sumRange`: Recursively explores the tree to find the segments that completely fall within
   the query range and sums them up. If a segment is partially within the range, it explores both children.

 Time Complexity:
 - Initialization (`init`): O(N) because we create 2N - 1 nodes in a full binary tree for N elements.
 - `update`: O(log N) because the height of the segment tree is O(log N) and we traverse one path.
 - `sumRange`: O(log N) because in the worst case we visit at most 4 nodes per level of the tree.

 Space Complexity:
 - O(N) to store the Segment Tree structure. A pointer-based Segment Tree for N elements creates exactly 2N - 1 nodes.
 - The recursion stack during build, update, and rangeQuery will also take O(log N) space.
 - Overall space complexity is O(N).
 */

class SegmentTree {
    class Node {
        var l: Int
        var r: Int
        var sum: Int
        var lChild: Node?
        var rChild: Node?
        
        init(_ l: Int, _ r: Int) {
            self.l = l
            self.r = r
            self.sum = 0
        }
    }
    
    private var root: Node?
    
    init(_ nums: [Int]) {
        root = build(nums, 0, nums.count - 1)
    }
    
    private func build(_ nums: [Int], _ l: Int, _ r: Int) -> Node {
        let node = Node(l, r)
        
        if l == r {
            node.sum = nums[l]
            return node
        }
        
        let mid = (l + r) / 2
        node.lChild = build(nums, l, mid)
        node.rChild = build(nums, mid + 1, r)
        node.sum = (node.lChild?.sum ?? 0) + (node.rChild?.sum ?? 0)
        
        return node
    }
    
    func update(_ index: Int, _ val: Int) {
        if let root = root {
            pointUpdate(root, index, val)
        }
    }
    
    private func pointUpdate(_ node: Node, _ index: Int, _ value: Int) {
        if node.l == node.r {
            node.sum = value
            return
        }
        
        let mid = (node.l + node.r) / 2
        if index <= mid {
            if let lChild = node.lChild {
                pointUpdate(lChild, index, value)
            }
        } else {
            if let rChild = node.rChild {
                pointUpdate(rChild, index, value)
            }
        }
        node.sum = (node.lChild?.sum ?? 0) + (node.rChild?.sum ?? 0)
    }
    
    func sumRange(_ left: Int, _ right: Int) -> Int {
        guard let root = root else { return 0 }
        return rangeQuery(root, left, right)
    }
    
    private func rangeQuery(_ node: Node, _ l: Int, _ r: Int) -> Int {
        
        //Case 1: No overlap
        if l > node.r || r < node.l {
            return 0
        }
        
        //Case 2: Complete overlap
        if l <= node.l && r >= node.r {
            return node.sum
        }
        
        //Case 3: Partial overlap.
        return rangeQuery(node.lChild!, l, r) + rangeQuery(node.rChild!, l, r) //Partial overlap means that the left and right child of the node are present as it is a complete binary tree.
    }
}

class NumArray {
    private var segTree: SegmentTree

    init(_ nums: [Int]) {
        segTree = SegmentTree(nums)
    }
    
    func update(_ index: Int, _ val: Int) {
        segTree.update(index, val)
    }
    
    func sumRange(_ left: Int, _ right: Int) -> Int {
        return segTree.sumRange(left, right)
    }
}
