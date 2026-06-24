//
//  09-LinkedList.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - ListNode  (class — reference semantics required for pointer tricks)

final class ListNode<T> {
    var val: T
    var next: ListNode<T>?

    init(_ val: T, _ next: ListNode<T>? = nil) {
        self.val  = val
        self.next = next
    }
}

// LeetCode-style typealias
// typealias ListNodeInt = ListNode<Int>

// MARK: - Singly Linked List

final class SinglyLinkedList<T: Equatable> {
    var head: ListNode<T>?
    var tail: ListNode<T>?
    private(set) var count = 0

    var isEmpty: Bool { head == nil }

    // O(1)
    func prepend(_ val: T) {
        let node = ListNode(val, head)
        head = node
        if tail == nil { tail = node }
        count += 1
    }

    // O(1) with tail pointer
    func append(_ val: T) {
        let node = ListNode(val)
        if let t = tail { t.next = node } else { head = node }
        tail = node
        count += 1
    }

    // Insert after a given node  O(1)
    func insert(_ val: T, after node: ListNode<T>) {
        let newNode = ListNode(val, node.next)
        if node.next == nil { tail = newNode }
        node.next = newNode
        count += 1
    }

    // Remove head  O(1)
    @discardableResult
    func removeHead() -> T? {
        guard let h = head else { return nil }
        head = h.next
        if head == nil { tail = nil }
        count -= 1
        return h.val
    }

    // Remove node after given node  O(1)
    @discardableResult
    func remove(after node: ListNode<T>) -> T? {
        guard let target = node.next else { return nil }
        if target.next == nil { tail = node }
        node.next = target.next
        count -= 1
        return target.val
    }

    // Search  O(n)
    func search(_ val: T) -> ListNode<T>? {
        var cur = head
        while let node = cur {
            if node.val == val { return node }
            cur = node.next
        }
        return nil
    }

    // Convert to array  O(n)
    func toArray() -> [T] {
        var result = [T]()
        var cur = head
        while let node = cur { result.append(node.val); cur = node.next }
        return result
    }

    // Print list
    func printList() {
        print(toArray().map { "\($0)" }.joined(separator: " → "))
    }
}

// MARK: - Doubly Linked List Node

final class DListNode<T> {
    var val:  T
    var prev: DListNode<T>?
    var next: DListNode<T>?

    init(_ val: T) { self.val = val }
}

// MARK: - Doubly Linked List

final class DoublyLinkedList<T: Equatable> {
    var head: DListNode<T>?
    var tail: DListNode<T>?
    private(set) var count = 0

    var isEmpty: Bool { head == nil }

    func prepend(_ val: T) {                          // O(1)
        let node = DListNode(val)
        node.next = head
        head?.prev = node
        head = node
        if tail == nil { tail = node }
        count += 1
    }

    func append(_ val: T) {                           // O(1)
        let node = DListNode(val)
        node.prev = tail
        tail?.next = node
        tail = node
        if head == nil { head = node }
        count += 1
    }

    func remove(_ node: DListNode<T>) {               // O(1) — given the node
        node.prev?.next = node.next
        node.next?.prev = node.prev
        if node === head { head = node.next }
        if node === tail { tail = node.prev }
        count -= 1
    }

    func moveToFront(_ node: DListNode<T>) {          // O(1)  used in LRU Cache
        remove(node)
        prepend(node.val)
    }
}

// MARK: - Algorithm: Reverse Singly Linked List — Iterative   O(n)

func reverseList<T>(_ head: ListNode<T>?) -> ListNode<T>? {
    var prev: ListNode<T>? = nil
    var curr = head
    while let node = curr {
        let next = node.next
        node.next = prev
        prev = node
        curr = next
    }
    return prev
}

// MARK: - Algorithm: Reverse — Recursive   O(n)

func reverseRecursive<T>(_ head: ListNode<T>?) -> ListNode<T>? {
    guard let node = head, node.next != nil else { return head }
    let newHead = reverseRecursive(node.next)
    node.next?.next = node
    node.next = nil
    return newHead
}

// MARK: - Algorithm: Floyd's Cycle Detection   O(n)

func hasCycle<T>(_ head: ListNode<T>?) -> Bool {
    var slow = head, fast = head?.next
    while let s = slow, let f = fast {
        if s === f { return true }
        slow = s.next
        fast = f.next?.next
    }
    return false
}

// Find start of cycle
func detectCycleStart<T>(_ head: ListNode<T>?) -> ListNode<T>? {
    var slow = head, fast = head
    // Phase 1: detect cycle
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        if slow === fast { break }
    }
    guard fast != nil && fast?.next != nil else { return nil }  // no cycle
    // Phase 2: find entry — move one pointer to head
    slow = head
    while slow !== fast {
        slow = slow?.next
        fast = fast?.next
    }
    return slow
}

// MARK: - Algorithm: Find Middle Node   O(n)

func findMiddle<T>(_ head: ListNode<T>?) -> ListNode<T>? {
    var slow = head, fast = head
    while fast?.next != nil && fast?.next?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }
    return slow   // for even length, returns second middle
}

// MARK: - Algorithm: Nth Node from End   O(n)

func nthFromEnd<T>(_ head: ListNode<T>?, _ n: Int) -> ListNode<T>? {
    var fast = head, slow = head
    for _ in 0..<n { fast = fast?.next }
    while fast != nil { fast = fast?.next; slow = slow?.next }
    return slow
}

// MARK: - Algorithm: Merge Two Sorted Lists   O(m + n)

func mergeSorted(_ l1: ListNode<Int>?, _ l2: ListNode<Int>?) -> ListNode<Int>? {
    let dummy = ListNode(0)
    var cur: ListNode<Int>? = dummy
    var a = l1, b = l2
    while let na = a, let nb = b {
        if na.val <= nb.val { cur?.next = na; a = na.next }
        else                { cur?.next = nb; b = nb.next }
        cur = cur?.next
    }
    cur?.next = a ?? b
    return dummy.next
}

// MARK: - Algorithm: Palindrome Linked List   O(n) time, O(1) space

func isPalindromeList(_ head: ListNode<Int>?) -> Bool {
    // 1. Find middle
    var slow = head, fast = head
    while fast?.next != nil && fast?.next?.next != nil {
        slow = slow?.next; fast = fast?.next?.next
    }
    // 2. Reverse second half
    var secondHalf = reverseList(slow?.next)
    // 3. Compare
    var p1 = head, p2 = secondHalf
    var result = true
    while p2 != nil {
        if p1?.val != p2?.val { result = false; break }
        p1 = p1?.next; p2 = p2?.next
    }
    // 4. Restore (optional — good practice in interviews)
    slow?.next = reverseList(secondHalf)
    return result
}

// MARK: - Algorithm: Intersection of Two Lists   O(m + n)

func getIntersection(_ headA: ListNode<Int>?, _ headB: ListNode<Int>?) -> ListNode<Int>? {
    var a = headA, b = headB
    while a !== b {
        a = a == nil ? headB : a?.next
        b = b == nil ? headA : b?.next
    }
    return a
}

// MARK: - LRU Cache (uses Doubly Linked List + HashMap)   O(1) get & put

final class LRUCache {
    private let capacity: Int
    private var cache = [Int: DListNode<(key: Int, val: Int)>]()
    private let list  = DoublyLinkedList<(key: Int, val: Int)>()

    init(_ capacity: Int) { self.capacity = capacity }

    func get(_ key: Int) -> Int {
        guard let node = cache[key] else { return -1 }
        // Move to front (most recently used)
        list.remove(node)
        list.prepend(node.val)
        cache[key] = list.head
        return node.val.val
    }

    func put(_ key: Int, _ value: Int) {
        if let node = cache[key] {
            list.remove(node)
        } else if list.count >= capacity {
            // Evict LRU (tail)
            if let lru = list.tail {
                cache.removeValue(forKey: lru.val.key)
                list.remove(lru)
            }
        }
        list.prepend((key: key, val: value))
        cache[key] = list.head
    }
}
