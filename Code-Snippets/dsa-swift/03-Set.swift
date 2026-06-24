//
//  03-Set.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Creation

var set: Set<Int> = Set([1, 9, 2, 5, 30])   // unordered, unique elements
var empty: Set<String> = []
var fromLiteral: Set<Int> = [1, 2, 3, 4]

// Note: Element must conform to Hashable

// MARK: - Basic Properties

// set.count        → Int
// set.isEmpty      → Bool

// MARK: - Insert & Remove

set.insert(10)                    // → (inserted: Bool, memberAfterInsert: Int)
set.remove(9)                     // → Element?   nil if not present
set.removeAll()                   // → Void

set = [1, 9, 2, 5, 30]

// MARK: - Query

set.contains(9)                   // → Bool   O(1) average
set.contains { $0 > 10 }         // → Bool   O(n)

// MARK: - Iteration

for element in set {
    _ = element   // order is not guaranteed
}

set.sorted()                      // → [Int]   sorted array  O(n log n)
set.sorted { $0 > $1 }           // → [Int]   descending

set.filter { $0 > 5 }            // → Set<Int>
set.forEach { _ = $0 }           // → Void

// Enumerate with offset
let arr = Array(set.enumerated())  // → [(offset: Int, element: Int)]

// MARK: - Set Algebra

var a: Set<Int> = [1, 2, 3, 4]
var b: Set<Int> = [3, 4, 5, 6]

// In-place (mutates a)
a.formUnion(b)                    // a = [1,2,3,4,5,6]   union
a = [1,2,3,4]
a.subtract(b)                     // a = [1,2]           removes elements of b from a
a = [1,2,3,4]
a.formIntersection(b)             // a = [3,4]           keeps only common
a = [1,2,3,4]
a.formSymmetricDifference(b)      // a = [1,2,5,6]       XOR — elements in one but not both

// Returns new set (non-mutating)
let union        = a.union(b)             // → Set<Int>   a ∪ b
let subtracted   = a.subtracting(b)       // → Set<Int>   a − b
let intersection = a.intersection(b)      // → Set<Int>   a ∩ b
let symDiff      = a.symmetricDifference(b) // → Set<Int> (a − b) ∪ (b − a)

// MARK: - Relationship Tests

a = [1, 2, 3, 4, 5]
b = [1, 2, 3]

a.isSuperset(of: b)               // → Bool  true   a ⊇ b
b.isSubset(of: a)                 // → Bool  true   b ⊆ a
a.isDisjoint(with: [6, 7])        // → Bool  true   no common elements

let c: Set<Int> = [1, 2, 3]
c.isSubset(of: a)                 // true
a.isStrictSuperset(of: c)         // true   a ⊋ c (strictly larger)
c.isStrictSubset(of: a)           // true

// MARK: - Stats

set = [3, 7, 2, 9, 1]
set.max()                         // → Int?   O(n)
set.min()                         // → Int?   O(n)
set.max { $0.magnitude < $1.magnitude }  // custom comparator
set.randomElement()               // → Int?

// MARK: - Conversion

let asArray = Array(set)          // → [Int]   unordered
let sorted  = set.sorted()        // → [Int]   sorted
let asSet   = Set([1, 2, 2, 3])   // → {1, 2, 3}   deduplication

// MARK: - Patterns

// ── Visited Set (DFS / BFS cycle detection) ──────────────────────────────────

func hasCycleDFS(graph: [Int: [Int]], start: Int) -> Bool {
    var visited = Set<Int>()
    var stack = [start]
    while !stack.isEmpty {
        let node = stack.removeLast()
        if visited.contains(node) { return true }
        visited.insert(node)
        for neighbor in graph[node, default: []] {
            stack.append(neighbor)
        }
    }
    return false
}

// ── Deduplication preserving order ───────────────────────────────────────────

func unique<T: Hashable>(_ arr: [T]) -> [T] {
    var seen = Set<T>()
    return arr.filter { seen.insert($0).inserted }
    // insert returns (inserted: Bool, …) — filter keeps first occurrences
}

// ── Frequency check — duplicates in array ────────────────────────────────────

func containsDuplicate(_ nums: [Int]) -> Bool {
    var seen = Set<Int>()
    for n in nums {
        if !seen.insert(n).inserted { return true }
    }
    return false
}

// ── Intersection of two arrays ───────────────────────────────────────────────

func intersect(_ a: [Int], _ b: [Int]) -> [Int] {
    let setB = Set(b)
    return a.filter { setB.contains($0) }
}

// ── Longest Consecutive Sequence   O(n) ─────────────────────────────────────

func longestConsecutive(_ nums: [Int]) -> Int {
    let numSet = Set(nums)
    var best = 0
    for n in numSet where !numSet.contains(n - 1) {  // only start of a sequence
        var len = 1
        var cur = n
        while numSet.contains(cur + 1) { cur += 1; len += 1 }
        best = max(best, len)
    }
    return best
}
