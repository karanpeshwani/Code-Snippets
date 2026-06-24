//
//  08-Heap.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//
//  Requires: swift-collections package
//  Add via Xcode → File → Add Package Dependencies
//  URL: https://github.com/apple/swift-collections
//

 import Collections

// MARK: - Heap<Element: Comparable>  (swift-collections)
// Min-max heap: O(1) access to BOTH min and max simultaneously

// Definition:
// public struct Heap<Element: Comparable>

// MARK: - Creation

// var heap = Heap<Int>()
// var heap = Heap([3, 1, 4, 1, 5, 9, 2, 6])   // heapify O(n)

// MARK: - Insert

// heap.insert(7)          → Void   O(log n)

// MARK: - Peek  (non-destructive)

// heap.min                → Element?   O(1)
// heap.max                → Element?   O(1)

// MARK: - Extract

// heap.popMin()           → Element?   O(log n)
// heap.popMax()           → Element?   O(log n)
// heap.removeMin()        → Element    O(log n)   crashes if empty
// heap.removeMax()        → Element    O(log n)   crashes if empty

// MARK: - Properties

// heap.count              → Int
// heap.isEmpty            → Bool
// heap.unordered          → [Element]   all elements, arbitrary order

// MARK: - Custom Ordering via Comparable wrapper

struct MaxFirst: Comparable {
    let val: Int
    static func < (a: MaxFirst, b: MaxFirst) -> Bool { a.val > b.val }
    // popMin() now removes the largest — acts as a max-heap
}

// Or use negative values trick for Int min-heap → max-heap:
// Insert -x, popMin() → -(-x) = x (largest first)

// MARK: - Manual Binary Heap Implementation
// Useful for interviews without swift-collections

struct BinaryHeap<T: Comparable> {
    private var heap = [T]()
    let isMinHeap: Bool   // true = min-heap, false = max-heap

    init(isMinHeap: Bool = true) { self.isMinHeap = isMinHeap }

    var isEmpty: Bool { heap.isEmpty }
    var count:   Int  { heap.count }
    var peek:    T?   { heap.first }

    private func hasHigherPriority(_ a: T, _ b: T) -> Bool {
        return isMinHeap ? a < b : a > b
    }

    mutating func insert(_ val: T) {
        heap.append(val)
        siftUp(heap.count - 1)
    }

    mutating func extractTop() -> T? {
        guard !heap.isEmpty else { return nil }
        if heap.count == 1 { return heap.removeLast() }
        let top = heap[0]
        heap[0] = heap.removeLast()
        siftDown(0)
        return top
    }

    private mutating func siftUp(_ i: Int) {
        var i = i
        while i > 0 {
            let parent = (i - 1) / 2
            if hasHigherPriority(heap[i], heap[parent]) {
                heap.swapAt(i, parent)
                i = parent
            } else { break }
        }
    }

    private mutating func siftDown(_ i: Int) {
        var i = i
        while true {
            let left  = 2 * i + 1
            let right = 2 * i + 2
            var top   = i
            if left  < heap.count && hasHigherPriority(heap[left],  heap[top]) { top = left  }
            if right < heap.count && hasHigherPriority(heap[right], heap[top]) { top = right }
            if top == i { break }
            heap.swapAt(i, top)
            i = top
        }
    }
}

// MARK: - Pattern: K Largest Elements   O(n log k)

func kLargest(_ nums: [Int], _ k: Int) -> [Int] {
    var minHeap = BinaryHeap<Int>(isMinHeap: true)
    for n in nums {
        minHeap.insert(n)
        if minHeap.count > k { minHeap.extractTop() }   // remove smallest
    }
    var result = [Int]()
    var copy   = minHeap
    while let top = copy.extractTop() { result.append(top) }
    return result.reversed()   // ascending → reverse for descending
}

// MARK: - Pattern: K Smallest Elements   O(n log k)

func kSmallest(_ nums: [Int], _ k: Int) -> [Int] {
    var maxHeap = BinaryHeap<Int>(isMinHeap: false)
    for n in nums {
        maxHeap.insert(n)
        if maxHeap.count > k { maxHeap.extractTop() }   // remove largest
    }
    var result = [Int]()
    var copy   = maxHeap
    while let top = copy.extractTop() { result.append(top) }
    return result
}

// MARK: - Pattern: Kth Largest Element   O(n log k)

func kthLargest(_ nums: [Int], _ k: Int) -> Int {
    var minHeap = BinaryHeap<Int>(isMinHeap: true)
    for n in nums {
        minHeap.insert(n)
        if minHeap.count > k { minHeap.extractTop() }
    }
    return minHeap.peek!    // top of min-heap = kth largest
}

// MARK: - Pattern: Running Median (Two Heaps)   O(log n) per insertion

struct RunningMedian {
    var lower = BinaryHeap<Int>(isMinHeap: false)  // max-heap: lower half
    var upper = BinaryHeap<Int>(isMinHeap: true)   // min-heap: upper half

    mutating func addNum(_ num: Int) {
        // Step 1: add to lower half
        lower.insert(num)

        // Step 2: balance (lower.top <= upper.top)
        if let lo = lower.peek, let up = upper.peek, lo > up {
            upper.insert(lower.extractTop()!)
        }

        // Step 3: balance sizes (lower can be at most 1 larger)
        if lower.count > upper.count + 1 {
            upper.insert(lower.extractTop()!)
        } else if upper.count > lower.count {
            lower.insert(upper.extractTop()!)
        }
    }

    func median() -> Double {
        if lower.count == upper.count {
            return Double(lower.peek! + upper.peek!) / 2.0
        }
        return Double(lower.peek!)
    }
}

// MARK: - Pattern: Merge K Sorted Arrays   O(n log k)

func mergeKSorted(_ arrays: [[Int]]) -> [Int] {
    // Element: (value, arrayIndex, elementIndex)
    var minHeap = BinaryHeap<[Int]>(isMinHeap: true)

    // Override: use manual tuple approach for clarity
    // Seed with first element of each array
    var heap2 = [(val: Int, arr: Int, idx: Int)]()

    for (i, arr) in arrays.enumerated() {
        if !arr.isEmpty { heap2.append((arr[0], i, 0)) }
    }
    heap2.sort { $0.val < $1.val }   // initial sort

    var result = [Int]()
    while !heap2.isEmpty {
        let top = heap2.removeFirst()
        result.append(top.val)
        let nextIdx = top.idx + 1
        if nextIdx < arrays[top.arr].count {
            let newItem = (arrays[top.arr][nextIdx], top.arr, nextIdx)
            // Insert in sorted position (use real heap in practice)
            let pos = heap2.firstIndex { $0.val > newItem.0 } ?? heap2.count
            heap2.insert(newItem, at: pos)
        }
    }
    return result
}

// MARK: - Pattern: Top K Frequent Words   O(n log k)

func topKWords(_ words: [String], _ k: Int) -> [String] {
    let freq = words.reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
    return freq
        .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
        .prefix(k)
        .map { $0.key }
}

// MARK: - Pattern: Dijkstra's Shortest Path (Priority Queue with Heap)

func dijkstra(graph: [Int: [(node: Int, weight: Int)]], start: Int, n: Int) -> [Int] {
    var dist = Array(repeating: Int.max, count: n)
    dist[start] = 0

    // (distance, node) — min-heap on distance
    var pq = [(dist: Int, node: Int)]()
    pq.append((0, start))
    pq.sort { $0.dist < $1.dist }   // use real heap in practice

    while !pq.isEmpty {
        let (d, u) = pq.removeFirst()
        if d > dist[u] { continue }   // stale entry

        for (v, w) in graph[u, default: []] {
            if dist[u] + w < dist[v] {
                dist[v] = dist[u] + w
                let pos = pq.firstIndex { $0.dist > dist[v] } ?? pq.count
                pq.insert((dist[v], v), at: pos)
            }
        }
    }
    return dist
}

// MARK: - Complexity Summary
//
//  Operation         BinaryHeap (manual)   Heap<T> (swift-collections)
//  insert            O(log n)              O(log n)
//  peekMin / peekMax O(1)                  O(1)
//  extractMin        O(log n)              O(log n)
//  extractMax        O(log n)              O(log n)   ← min-max heap advantage
//  build from array  O(n)                  O(n)
//
//  swift-collections Heap is a min-max heap — O(1) access to BOTH min and max
//  Standard binary heap only gives O(1) access to one extreme
