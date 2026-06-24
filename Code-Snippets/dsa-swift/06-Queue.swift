//
//  06-Queue.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Queue Basics
// FIFO: First In, First Out
// Enqueue at back, dequeue from front

// MARK: - Naive Array Queue  ⚠️ O(n) dequeue

struct NaiveQueue<T> {
    private var storage = [T]()

    var isEmpty: Bool { storage.isEmpty }
    var count: Int    { storage.count }
    var front: T?     { storage.first }

    mutating func enqueue(_ val: T) { storage.append(val) }       // O(1)

    @discardableResult
    mutating func dequeue() -> T? {
        guard !storage.isEmpty else { return nil }
        return storage.removeFirst()    // ⚠️ O(n) — shifts all elements
    }
}

// MARK: - Efficient Queue — Two Stacks   Amortised O(1)

struct TwoStackQueue<T> {
    private var inbox  = [T]()   // enqueue here
    private var outbox = [T]()   // dequeue from here

    var isEmpty: Bool { inbox.isEmpty && outbox.isEmpty }
    var count: Int    { inbox.count + outbox.count }
    var front: T? {
        if !outbox.isEmpty { return outbox.last }
        return inbox.first
    }

    mutating func enqueue(_ val: T) {
        inbox.append(val)                                       // O(1)
    }

    @discardableResult
    mutating func dequeue() -> T? {
        if outbox.isEmpty {
            outbox = inbox.reversed()                           // O(n) — amortised O(1) per op
            inbox.removeAll()
        }
        return outbox.popLast()                                 // O(1)
    }
}

// MARK: - Preferred: Use Deque from swift-collections
// See 07-Deque.swift — O(1) enqueue and dequeue
// import Collections
// var queue = Deque<Int>()
// queue.append(1)         enqueue
// queue.popFirst()        dequeue

// MARK: - Circular Queue  (fixed capacity, O(1) all ops)

struct CircularQueue<T> {
    private var buffer: [T?]
    private var head = 0
    private var tail = 0
    private var count_ = 0
    let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = Array(repeating: nil, count: capacity)
    }

    var isEmpty: Bool { count_ == 0 }
    var isFull:  Bool { count_ == capacity }
    var front:   T?   { buffer[head] }

    mutating func enqueue(_ val: T) -> Bool {
        guard !isFull else { return false }
        buffer[tail] = val
        tail = (tail + 1) % capacity
        count_ += 1
        return true
    }

    mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }
        let val = buffer[head]
        buffer[head] = nil
        head = (head + 1) % capacity
        count_ -= 1
        return val
    }
}

// MARK: - Pattern: BFS Level-Order Traversal Template

class BFSNode {
    var val: Int
    var neighbors: [BFSNode]
    init(_ val: Int) { self.val = val; self.neighbors = [] }
}

func bfs(start: BFSNode) -> [[Int]] {
    var result = [[Int]]()
    var queue  = [BFSNode]()
    var visited = Set<ObjectIdentifier>()

    queue.append(start)
    visited.insert(ObjectIdentifier(start))

    while !queue.isEmpty {
        let levelSize = queue.count
        var level = [Int]()

        for _ in 0..<levelSize {
            let node = queue.removeFirst()          // use Deque in practice
            level.append(node.val)
            for neighbor in node.neighbors {
                let id = ObjectIdentifier(neighbor)
                if !visited.contains(id) {
                    visited.insert(id)
                    queue.append(neighbor)
                }
            }
        }
        result.append(level)
    }
    return result
}

// MARK: - Pattern: BFS Shortest Path on Grid

func shortestPath(grid: [[Int]], start: (Int, Int), end: (Int, Int)) -> Int {
    let rows = grid.count, cols = grid[0].count
    let dirs = [(0,1),(0,-1),(1,0),(-1,0)]
    var visited = Set<String>()
    var queue   = [(row: Int, col: Int, dist: Int)]()

    queue.append((start.0, start.1, 0))
    visited.insert("\(start.0),\(start.1)")

    while !queue.isEmpty {
        let (r, c, dist) = queue.removeFirst()   // use Deque in practice
        if (r, c) == end { return dist }

        for (dr, dc) in dirs {
            let nr = r + dr, nc = c + dc
            let key = "\(nr),\(nc)"
            guard nr >= 0, nr < rows, nc >= 0, nc < cols,
                  grid[nr][nc] == 0, !visited.contains(key) else { continue }
            visited.insert(key)
            queue.append((nr, nc, dist + 1))
        }
    }
    return -1   // no path
}

// MARK: - Pattern: Sliding Window Maximum using Queue (monotonic deque)
// Covered in detail in 07-Deque.swift

// MARK: - Pattern: Open the Lock (LC 752) — BFS on state space

func openLock(deadends: [String], target: String) -> Int {
    var dead  = Set(deadends)
    var seen  = Set<String>()
    var queue = [String]()
    let start = "0000"

    if dead.contains(start) { return -1 }
    queue.append(start); seen.insert(start)
    var steps = 0

    while !queue.isEmpty {
        let size = queue.count
        for _ in 0..<size {
            let curr = queue.removeFirst()
            if curr == target { return steps }
            for i in 0..<4 {
                for delta in [-1, 1] {
                    var chars = Array(curr)
                    let digit = (Int(String(chars[i]))! + delta + 10) % 10
                    chars[i] = Character(String(digit))
                    let next = String(chars)
                    if !seen.contains(next) && !dead.contains(next) {
                        seen.insert(next)
                        queue.append(next)
                    }
                }
            }
        }
        steps += 1
    }
    return -1
}
