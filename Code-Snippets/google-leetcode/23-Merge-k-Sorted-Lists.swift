// 23. Merge k Sorted Lists
// Link: https://leetcode.com/problems/merge-k-sorted-lists/
//
// Time Complexity: O(N log k), where N is the total number of nodes and k is the number of linked lists.
// Explanation: The heap size is at most k. We insert and pop N times, each taking O(log k) time.
// Space Complexity: O(k)
// Explanation: The heap stores at most one node from each of the k linked lists at any given time.

import Collections

// Definition for singly-linked list.
public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

extension ListNode: Comparable {
    public static func < (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.val < rhs.val
    }
    
    public static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs === rhs
    }
}

class Solution {
    func mergeKLists(_ lists: [ListNode?]) -> ListNode? {
        // A min-heap to keep track of the minimum nodes among the heads of all k lists
        var heap = Heap<ListNode>()
        
        // Add the head of each non-empty list to the heap
        for list in lists {
            if let node = list {
                heap.insert(node)
            }
        }
        
        // Dummy head to simplify result list construction
        let dummy = ListNode(0)
        var tail = dummy
        
        // Continually extract the minimum node and push its next node onto the heap
        while !heap.isEmpty {
            let minNode = heap.removeMin()
            tail.next = minNode
            tail = minNode
            
            // If the extracted node has a next node, insert it into the heap
            if let nextNode = minNode.next {
                heap.insert(nextNode)
            }
        }
        
        return dummy.next
    }
}
