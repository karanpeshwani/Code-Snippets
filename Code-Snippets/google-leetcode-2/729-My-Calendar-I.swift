//Segment Tree
//https://leetcode.com/problems/my-calendar-i/

/*
 Here is the breakdown of the time and space complexity for this Dynamic Segment Tree solution.
 Let N be the number of events (calls to book), and M be the maximum possible time range (10^9).
 Time Complexity: O(N log M) overall
 Per book operation: O(log M)
 Why?
 The maximum depth of our segment tree is bounded by the halving of the time range. Since we start with a range of 10^9 and split it in half at each level, the maximum depth of the tree is log2(10^9) ≈ 30 levels.
 During both query and update, at any given level of the tree, we visit a maximum of 4 nodes (because the requested range can span across the midpoint, forcing us to check both the left and right children). Since we only go down at most 30 levels, a single book operation takes O(log M) time. For N bookings, the total time is O(N log M).
 Space Complexity: O(N log M) overall
 Why?
 If we built a standard segment tree array for a range of 10^9, we would need 4 × 10^9 nodes, which would cause a massive Memory Limit Exceeded (MLE) error.
 Because we are using a Dynamic Segment Tree, we only create nodes when we need them.
 Every time we call update, we traverse down the tree from the root to the exact range interval. This path has a maximum length of log2(M) ≈ 30. Therefore, a single book operation will dynamically instantiate at most O(log M) new nodes.
 If we process N bookings, we will create a maximum of N × log2(M) nodes. In LeetCode's My Calendar I, N ≤ 1000. This means in the absolute worst-case scenario, we only create about 1000 × 30 = 30,000 nodes. This is extremely memory efficient and easily passes the memory limits.

*/

class MyCalendar {
    
    // The building block of our Dynamic Segment Tree.
    // Each node represents a specific window of time from L to R.
    class Node {
        let L: Int
        let R: Int
        var left: Node?
        var right: Node?
        
        // True if this entire time window [L, R] is completely booked.
        var isBooked: Bool = false
        
        init(L: Int, R: Int) {
            self.L = L
            self.R = R
        }
    }
    
    // The root of the tree represents the maximum possible time range given
    // by the problem constraints (0 to 10^9).
    private let root = Node(L: 0, R: 1_000_000_000)
    
    func book(_ start: Int, _ end: Int) -> Bool {
        // The problem states the interval is [start, end), meaning 'end' is exclusive.
        // We convert it to a fully inclusive interval [start, end - 1] for easier math.
        let bookingEnd = end - 1
        
        // Step 1: Check if there is ANY overlap in the requested time range.
        if query(node: root, start: start, end: bookingEnd) {
            return false // Time slot is taken, booking fails.
        }
        
        // Step 2: If no overlap was found, permanently mark this time range as booked.
        update(node: root, start: start, end: bookingEnd)
        return true
    }
    
    // Returns true if there is an existing booking that overlaps with [start, end].
    private func query(node: Node, start: Int, end: Int) -> Bool {
        // Base Case 1: If this entire node's time range is already booked,
        // then any query overlapping it will conflict.
        if node.isBooked {
            return true
        }
        
        // Base Case 2: Out of bounds. If the node's range is completely outside
        // the requested range, there is no conflict here.
        if node.L > end || node.R < start {
            return false
        }
        
        // Find the midpoint of the CURRENT node's time range to decide which child to search.
        let mid = (node.L + node.R) / 2
        
        // If the requested range falls into the left half, and the left child exists, search it.
        if let left = node.left, start <= mid {
            if query(node: left, start: start, end: end) { return true }
        }
        
        // If the requested range falls into the right half, and the right child exists, search it.
        if let right = node.right, end > mid {
            if query(node: right, start: start, end: end) { return true }
        }
        
        // If we checked the relevant branches and found no conflicts, the slot is free.
        return false
    }
    
    // Marks the range [start, end] as booked within the tree.
    private func update(node: Node, start: Int, end: Int) {
        // Base Case 1: If this node is already fully booked, we don't need to do anything.
        if node.isBooked { return }
        
        // Base Case 2: If the requested range completely covers this node's range,
        // mark this node as fully booked and stop traveling deeper.
        if node.L >= start && node.R <= end {
            node.isBooked = true
            return
        }
        
        // Find the midpoint to split the time range and traverse downwards.
        let mid = node.L + (node.R - node.L) / 2
        
        // If the booking overlaps with the left half...
        if start <= mid {
            // ...dynamically create the left child if it doesn't exist yet...
            if node.left == nil { node.left = Node(L: node.L, R: mid) }
            // ...and recursively update it.
            update(node: node.left!, start: start, end: end)
        }
        
        // If the booking overlaps with the right half...
        if end > mid {
            // ...dynamically create the right child if it doesn't exist yet...
            if node.right == nil { node.right = Node(L: mid + 1, R: node.R) }
            // ...and recursively update it.
            update(node: node.right!, start: start, end: end)
        }
        
        // Optimization (Tree Consolidation):
        // If both children end up fully booked, the parent is effectively fully booked too.
        // We bubble this state up to save time on future queries.
        if let left = node.left, let right = node.right, left.isBooked && right.isBooked {
            node.isBooked = true
        }
    }
}
