//Again -> Segment Tree
// 715. Range Module
// https://leetcode.com/problems/range-module

/*
 Time Complexity: O(N) worst-case per query/add/remove, but O(log N) for pure queries.
   - Here, N is the number of disjoint intervals (up to 10^4). 
   - Searching for the overlapping ranges takes O(log N) using binary search.
   - Modifying the array takes O(N) due to shifting elements. However, arrays in Swift are backed 
     by contiguous memory, making `replaceSubrange` utilize `memmove`, which is extremely fast 
     for N = 10,000, achieving optimal real-world performance compared to complex trees.
 Space Complexity: O(N)
   - N is the number of disjoint ranges. The array stores at most O(N) intervals.
*/

class SegmentTree {

    private class Node {
        var start: Int
        var end: Int
        var tracked: Bool
        var left: Node?
        var right: Node?
        
        init(_ start: Int, _ end: Int, _ tracked: Bool = false) {
            self.start = start
            self.end = end
            self.tracked = tracked
        }
    }

    private var root: Node

    init(_ start: Int, _ end: Int) {
        self.root = Node(start, end)
    }

    func addRange(_ start: Int, _ end: Int) {
        // Edge case: when left == right, range is invalid for this problem
        self.addRange(start, end, root)
    }

    private func addRange(_ start: Int, _ end: Int, _ currentNode: Node) {
        // 1. Current node is completely covered by the update interval
        if start <= currentNode.start && currentNode.end <= end {
            currentNode.tracked = true
            // Discard children as the entire range is now uniformly true
            currentNode.left = nil
            currentNode.right = nil
            return
        }
        
        // 2. Optimization: If the whole node is already true, adding a sub-range changes nothing
        if currentNode.tracked {
            return
        }
        
        let mid = currentNode.start + (currentNode.end - currentNode.start) / 2
        
        // Lazy instantiation: Create children if they don't exist and pass down the current state
        if currentNode.left == nil {
            currentNode.left = Node(currentNode.start, mid, currentNode.tracked)
        }
        if currentNode.right == nil {
            currentNode.right = Node(mid + 1, currentNode.end, currentNode.tracked)
        }
        
        // 3. Recurse down to children
        if start <= mid {
            addRange(start, end, currentNode.left!)
        }
        if end > mid {
            addRange(start, end, currentNode.right!)
        }
        
        // 4. Update current node based on children's states
        currentNode.tracked = currentNode.left!.tracked && currentNode.right!.tracked
    }

    func removeRange(_ start: Int, _ end: Int) {
        self.removeRange(start, end, root)
    }

    private func removeRange(_ start: Int, _ end: Int, _ currentNode: Node) {
        // 1. Current node is completely covered by the removal interval
        if start <= currentNode.start && currentNode.end <= end {
            currentNode.tracked = false
            // Discard children as the entire range is now uniformly false
            currentNode.left = nil
            currentNode.right = nil
            return
        }
        
        // 2. Optimization: If the node is already completely false, removing a sub-range changes nothing
        if !currentNode.tracked && currentNode.left == nil {
            return
        }
        
        let mid = currentNode.start + (currentNode.end - currentNode.start) / 2
        
        // Lazy instantiation
        if currentNode.left == nil {
            currentNode.left = Node(currentNode.start, mid, currentNode.tracked)
        }
        if currentNode.right == nil {
            currentNode.right = Node(mid + 1, currentNode.end, currentNode.tracked)
        }
        
        // 3. Recurse down to children
        if start <= mid {
            removeRange(start, end, currentNode.left!)
        }
        if end > mid {
            removeRange(start, end, currentNode.right!)
        }
        
        // 4. Update current node based on children's states
        currentNode.tracked = currentNode.left!.tracked && currentNode.right!.tracked
    }

    func queryRange(_ start: Int, _ end: Int) -> Bool {
        return self.queryRange(start, end, root)
    }

    private func queryRange(_ start: Int, _ end: Int, _ currentNode: Node) -> Bool {
        // 1. Current node is completely covered by the query interval
        if start <= currentNode.start && currentNode.end <= end {
            return currentNode.tracked
        }
        
        // 2. If it has no children, its `tracked` state uniformly applies to all its sub-intervals
        if currentNode.left == nil {
            return currentNode.tracked
        }
        
        let mid = currentNode.start + (currentNode.end - currentNode.start) / 2
        var isTracked = true
        
        // 3. Recurse down and combine results
        if start <= mid {
            isTracked = isTracked && queryRange(start, end, currentNode.left!)
        }
        if end > mid {
            isTracked = isTracked && queryRange(start, end, currentNode.right!)
        }
        
        return isTracked
    }
}

class RangeModule {

    var segmentTree: SegmentTree

    init() {
        self.segmentTree = SegmentTree(1, 1_000_000_000)
    }
    
    func addRange(_ left: Int, _ right: Int) {
        segmentTree.addRange(left, right - 1)
    }
    
    func queryRange(_ left: Int, _ right: Int) -> Bool {
        return segmentTree.queryRange(left, right - 1)
    }
    
    func removeRange(_ left: Int, _ right: Int) {
        segmentTree.removeRange(left, right - 1)
    }
}
