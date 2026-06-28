//Again
// 25. Reverse Nodes in k-Group
// https://leetcode.com/problems/reverse-nodes-in-k-group
//
// Time Complexity: O(N)
// Space Complexity: O(1)
//
// Explanation:
// We reverse the linked list in groups of `k`.
// We use a dummy node to simplify the handling of the head of the list.
// In a loop, we first check if there are at least `k` nodes remaining to be reversed. 
// If there are, we reverse this group of `k` nodes using standard pointer manipulation (prev, current, next).
// The `groupPrev` pointer always points to the node just before the current group being reversed.
// After reversing a group, the original first node of the group becomes the last node, so we update `groupPrev` to this node.
// If there are fewer than `k` nodes left, we break the loop and leave them as they are.
// Space complexity is O(1) as we are only using a few pointers, and Time complexity is O(N) since each node is visited at most twice.

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

class Solution {
    func reverseKGroup(_ head: ListNode?, _ k: Int) -> ListNode? {
        if head == nil || k == 1 {
            return head
        }
        
        let dummy = ListNode(0)
        dummy.next = head
        var groupPrev: ListNode? = dummy
        
        while true {
            // Check if there are at least k nodes left
            var kth: ListNode? = groupPrev
            for _ in 0..<k {
                kth = kth?.next
                if kth == nil {
                    break
                }
            }
            
            // If fewer than k nodes left, we are done
            if kth == nil {
                break
            }
            
            let groupNext = kth?.next
            
            // Reverse the group
            var prev: ListNode? = groupNext
            var curr = groupPrev?.next
            let originalGroupFirst = curr // This will become the last node in the group
            
            for _ in 0..<k {
                let nextTemp = curr?.next
                curr?.next = prev
                prev = curr
                curr = nextTemp
            }
            
            // Update pointers connecting the reversed group to the rest of the list
            groupPrev?.next = prev
            groupPrev = originalGroupFirst
        }
        
        return dummy.next
    }
}
