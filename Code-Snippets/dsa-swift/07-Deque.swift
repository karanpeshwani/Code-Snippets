//
//  07-Deque.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//
//  Requires: swift-collections package
//  Add via Xcode → File → Add Package Dependencies
//  URL: https://github.com/apple/swift-collections
//

 import Collections

// MARK: - Deque<T>  (Double-Ended Queue)
// O(1) insert/remove from BOTH front and back
// Backed by a circular buffer — superior to Array for queue operations

// MARK: - Creation

// var deque: Deque<Int> = []
// var deque = Deque<Int>()
// var deque = Deque([1, 2, 3, 4, 5])    // from array
// var deque: Deque = [1, 2, 3]          // literal

// MARK: - Append (Back)

// deque.append(10)          → Void   O(1)   add to back
// deque.append(contentsOf: [11, 12])   → Void   O(k)

// MARK: - Prepend (Front)

// deque.prepend(0)          → Void   O(1)   add to front
// deque.prepend(contentsOf: [-2, -1]) → Void   O(k)

// MARK: - Remove (Back)

// deque.popLast()           → T?    O(1)
// deque.removeLast()        → T     O(1)   crashes if empty
// deque.removeLast(2)       → Void   O(k)

// MARK: - Remove (Front)

// deque.popFirst()          → T?    O(1)
// deque.removeFirst()       → T     O(1)   crashes if empty
// deque.removeFirst(2)      → Void   O(k)

// MARK: - Peek

// deque.first               → T?   front element, no removal
// deque.last                → T?   back element,  no removal

// MARK: - Access & Properties

// deque[i]                  → T     O(1) random access
// deque.count               → Int
// deque.isEmpty             → Bool
// deque.startIndex          → Int   always 0
// deque.endIndex            → Int   = count

// MARK: - Iteration  (full Collection conformance)

// for element in deque { }
// deque.forEach { }
// deque.map { }
// deque.filter { }
// deque.contains { }
// deque.enumerated()
// Array(deque)              → [T]

// MARK: - Pattern: Deque as Queue (preferred over naive array)

// var queue = Deque<Int>()
// queue.append(1)           enqueue at back   O(1)
// queue.popFirst()          dequeue from front O(1)
// queue.first               peek front        O(1)

// MARK: - Pattern: Deque as Stack

// var stack = Deque<Int>()
// stack.append(1)           push              O(1)
// stack.popLast()           pop               O(1)
// stack.last                peek              O(1)

// MARK: - Pattern: Sliding Window Maximum   O(n)
// Use a monotonic deque storing indices in decreasing order of their values

func slidingWindowMax(_ nums: [Int], _ k: Int) -> [Int] {
    // Using array-based deque manually (replace with Deque<Int> in practice)
    var dq     = [Int]()   // stores indices, front = max element index
    var result = [Int]()

    for i in 0..<nums.count {
        // Remove indices outside the current window
        if let front = dq.first, front < i - k + 1 {
            dq.removeFirst()                          // O(1) with real Deque
        }
        // Remove indices from back whose values are <= nums[i]
        while let back = dq.last, nums[back] <= nums[i] {
            dq.removeLast()                           // O(1)
        }
        dq.append(i)

        if i >= k - 1 {
            result.append(nums[dq.first!])            // front always holds max
        }
    }
    return result
}

// MARK: - Pattern: Jump Game — BFS with Deque

func canJump(_ nums: [Int]) -> Bool {
    var maxReach = 0
    for (i, n) in nums.enumerated() {
        if i > maxReach { return false }
        maxReach = max(maxReach, i + n)
    }
    return true
}

// MARK: - Pattern: First Negative in Every Window of Size K

func firstNegativeInWindow(_ nums: [Int], _ k: Int) -> [Int] {
    var dq     = [Int]()   // stores indices of negative numbers
    var result = [Int]()

    for i in 0..<nums.count {
        // Remove indices out of window
        if let front = dq.first, front < i - k + 1 { dq.removeFirst() }
        // Add current if negative
        if nums[i] < 0 { dq.append(i) }

        if i >= k - 1 {
            result.append(dq.isEmpty ? 0 : nums[dq.first!])
        }
    }
    return result
}

// MARK: - Pattern: Maximum of All Subarrays — Deque vs Naive
// Naive: O(n*k)  |  Monotonic Deque: O(n)

// MARK: - Pattern: Palindrome Check with Deque

func isPalindromeDeque(_ word: String) -> Bool {
    var dq = Array(word)     // replace with Deque<Character> in practice
    while dq.count > 1 {
        if dq.first != dq.last { return false }
        dq.removeFirst()
        dq.removeLast()
    }
    return true
}

// MARK: - Complexity Summary
//
//  Operation          Array (as deque)    Deque<T>
//  append (back)      O(1) amortised      O(1)
//  removeLast         O(1)                O(1)
//  insert(at:0)       O(n)  ← bad         O(1)
//  removeFirst        O(n)  ← bad         O(1)
//  random access [i]  O(1)                O(1)
//  memory             contiguous          chunked ring buffer
