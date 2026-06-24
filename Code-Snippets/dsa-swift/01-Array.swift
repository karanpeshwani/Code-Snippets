//
//  01-Array.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Creation

var arr: [Int] = [1, 9, 2, 5, 30]

let zeros   = Array(repeating: 0, count: 5)                               // [0, 0, 0, 0, 0]
let filled  = Array(repeating: -1, count: 3)                              // [-1, -1, -1]
let range1  = Array(0..<5)                                                // [0, 1, 2, 3, 4]
let range2  = Array(1...5)                                                // [1, 2, 3, 4, 5]

// 2D array  (rows × cols, all 0)
var matrix  = Array(repeating: Array(repeating: 0, count: 4), count: 3)  // 3×4
var matrix2: [[Int]] = [[1,2,3],[4,5,6],[7,8,9]]

let fromString = Array("hello")                                           // [Character]
let zipped     = Array(zip([1,2,3], ["a","b","c"]))                      // [(1,"a"),…]

// MARK: - Basic Properties

// arr.count         → Int
// arr.isEmpty       → Bool
// arr.first         → Element?   nil if empty
// arr.last          → Element?   nil if empty
// arr.startIndex    → Int        always 0
// arr.endIndex      → Int        = count (one past last)

// MARK: - Access & Slicing

// arr[0]            → Element         crashes if out of bounds
// arr[1...3]        → ArraySlice<Int>  [9, 2, 5]
// arr[1..<3]        → ArraySlice<Int>  [9, 2]
// arr[..<2]         → ArraySlice<Int>  [1, 9]
// arr[2...]         → ArraySlice<Int>  [2, 5, 30]
let sliced = Array(arr[1...3])  // convert ArraySlice → Array

// Safe index access (avoids crash)
func safeGet<T>(_ arr: [T], _ i: Int) -> T? {
    guard i >= 0 && i < arr.count else { return nil }
    return arr[i]
}

// MARK: - Mutation

var a = [1, 2, 3]

a.append(4)                             // → Void   O(1) amortised   [1,2,3,4]
a.append(contentsOf: [5, 6])            // → Void   O(k)             [1,2,3,4,5,6]
a.insert(0, at: 0)                      // → Void   O(n)             [0,1,2,3,4,5,6]
a.insert(contentsOf: [10, 11], at: 2)   // → Void   O(n)

a.remove(at: 0)                         // → Element  O(n)
a.removeFirst()                         // → Element  O(n)
a.removeFirst(2)                        // → Void     removes first 2   O(n)
a.removeLast()                          // → Element  O(1)
a.removeLast(2)                         // → Void     O(1)
a.removeAll()                           // → Void
a.removeAll { $0 > 10 }                // → Void     remove matching
// a.removeSubrange(1...3)              // → Void

a = [1, 2, 3, 4, 5]
a.swapAt(0, 4)                          // → Void   O(1)   [5,2,3,4,1]

// MARK: - Search

let b = [3, 7, 2, 9, 1, 7]

// b.contains(7)                        → Bool      O(n)
// b.contains { $0 > 8 }               → Bool      O(n)
// b.firstIndex(of: 7)                  → Int?  →  1    O(n)
// b.lastIndex(of: 7)                   → Int?  →  5    O(n)
// b.firstIndex { $0 > 5 }             → Int?  →  1    O(n)
// b.lastIndex  { $0 > 5 }             → Int?  →  3    O(n)

// MARK: - Transform

let nums = [1, 2, 3, 4, 5]

// nums.map     { $0 * 2 }              → [Int]         [2,4,6,8,10]
// nums.filter  { $0 % 2 == 0 }        → [Int]         [2,4]
// nums.reduce(0, +)                    → Int           15
// nums.reduce(0) { $0 + $1 }          → Int           15

let nested = [[1,2],[3,4],[5,6]]
// nested.flatMap { $0 }               → [Int]   [1,2,3,4,5,6]

let optionals: [Int?] = [1, nil, 3, nil, 5]
// optionals.compactMap { $0 }         → [Int]   [1,3,5]

// nums.forEach { print($0) }          → Void

// MARK: - Enumeration

for (index, value) in nums.enumerated() {
    _ = (index, value)  // index: 0…4, value: 1…5
}
// Array(arr.enumerated()) → [(offset: 0, element: 1), (offset: 1, element: 2), ...]

// MARK: - Sort

var c = [3, 1, 4, 1, 5, 9, 2]

c.sort()                                // in-place ascending    O(n log n)
c.sort { $0 > $1 }                      // in-place descending

let ascSorted  = c.sorted()             // → new array ascending
let descSorted = c.sorted { $0 > $1 }   // → new array descending

// Sorting structs
struct PersonA { var name: String; var age: Int }
var people = [PersonA(name: "Bob", age: 30), PersonA(name: "Alice", age: 25)]
people.sort { $0.age < $1.age }         // by age asc
people.sort { $0.name < $1.name }       // by name lexicographic

// MARK: - Reorder

c.reverse()                             // in-place   O(n)
// Array(c.reversed())                  → new reversed array   O(n)

// Array(c.dropFirst())                 → drop 1 from front
// Array(c.dropFirst(3))                → drop 3 from front
// Array(c.dropLast())                  → drop 1 from back
// Array(c.dropLast(2))                 → drop 2 from back
// Array(c.prefix(3))                   → first 3 elements
// Array(c.suffix(2))                   → last 2 elements

// MARK: - Stats

// c.max()                              → Element?   O(n)
// c.min()                              → Element?   O(n)
// c.max { $0 < $1 }                   → Element?   custom comparator
// c.min { $0 < $1 }                   → Element?
// c.randomElement()                    → Element?

// MARK: - Algorithm: Binary Search   O(log n)  requires sorted array

func binarySearch(_ arr: [Int], _ target: Int) -> Int {
    var lo = 0, hi = arr.count - 1
    while lo <= hi {
        let mid = lo + (hi - lo) / 2   // avoids integer overflow
        if arr[mid] == target      { return mid }
        else if arr[mid] < target  { lo = mid + 1 }
        else                       { hi = mid - 1 }
    }
    return -1   // not found
}

// Lower bound: first index where arr[i] >= target
func lowerBound(_ arr: [Int], _ target: Int) -> Int {
    var lo = 0, hi = arr.count
    while lo < hi {
        let mid = lo + (hi - lo) / 2
        arr[mid] < target ? (lo = mid + 1) : (hi = mid)
    }
    return lo   // valid insert position in [0, count]
}

// Upper bound: first index where arr[i] > target
func upperBound(_ arr: [Int], _ target: Int) -> Int {
    var lo = 0, hi = arr.count
    while lo < hi {
        let mid = lo + (hi - lo) / 2
        arr[mid] <= target ? (lo = mid + 1) : (hi = mid)
    }
    return lo
}

// MARK: - Algorithm: Two Pointer   O(n)

func twoSumSorted(_ arr: [Int], target: Int) -> (Int, Int)? {
    var lo = 0, hi = arr.count - 1
    while lo < hi {
        let sum = arr[lo] + arr[hi]
        if sum == target { return (lo, hi) }
        sum < target ? (lo += 1) : (hi -= 1)
    }
    return nil
}

func isPalindromeArr(_ arr: [Int]) -> Bool {
    var lo = 0, hi = arr.count - 1
    while lo < hi {
        if arr[lo] != arr[hi] { return false }
        lo += 1; hi -= 1
    }
    return true
}

// Container with most water (LC 11)
func maxWater(_ h: [Int]) -> Int {
    var lo = 0, hi = h.count - 1, best = 0
    while lo < hi {
        best = max(best, min(h[lo], h[hi]) * (hi - lo))
        h[lo] < h[hi] ? (lo += 1) : (hi -= 1)
    }
    return best
}

// MARK: - Algorithm: Sliding Window — Fixed Size   O(n)

func maxSumFixed(_ arr: [Int], k: Int) -> Int {
    guard arr.count >= k else { return 0 }
    var win = arr[0..<k].reduce(0, +)
    var best = win
    for i in k..<arr.count {
        win += arr[i] - arr[i - k]
        best = max(best, win)
    }
    return best
}

// MARK: - Algorithm: Sliding Window — Variable Size   O(n)

func minLenSubarraySum(_ arr: [Int], _ target: Int) -> Int {
    var lo = 0, sum = 0, minLen = Int.max
    for hi in 0..<arr.count {
        sum += arr[hi]
        while sum >= target {
            minLen = min(minLen, hi - lo + 1)
            sum -= arr[lo]; lo += 1
        }
    }
    return minLen == Int.max ? 0 : minLen
}

// MARK: - Algorithm: Prefix Sum   O(n) build, O(1) range query

func buildPrefix(_ arr: [Int]) -> [Int] {
    var p = Array(repeating: 0, count: arr.count + 1)
    for i in 0..<arr.count { p[i + 1] = p[i] + arr[i] }
    return p
}

// range sum inclusive [l, r]:
// prefix[r + 1] - prefix[l]

// MARK: - Algorithm: Kadane's — Max Subarray Sum   O(n)

func maxSubarraySum(_ arr: [Int]) -> Int {
    var best = arr[0], cur = arr[0]
    for i in 1..<arr.count {
        cur  = max(arr[i], cur + arr[i])
        best = max(best, cur)
    }
    return best
}

// MARK: - Algorithm: Dutch National Flag (3-way partition)   O(n)
// Sort array of 0s, 1s, 2s in-place

func dutchFlag(_ arr: inout [Int]) {
    var lo = 0, mid = 0, hi = arr.count - 1
    while mid <= hi {
        switch arr[mid] {
        case 0:  arr.swapAt(lo, mid); lo += 1; mid += 1
        case 1:  mid += 1
        default: arr.swapAt(mid, hi); hi -= 1  // don't advance mid
        }
    }
}

// MARK: - Algorithm: Merge Intervals   O(n log n)

func mergeIntervals(_ intervals: [[Int]]) -> [[Int]] {
    guard !intervals.isEmpty else { return [] }
    let sorted = intervals.sorted { $0[0] < $1[0] }
    var result = [sorted[0]]
    for iv in sorted.dropFirst() {
        if iv[0] <= result.last![1] {
            result[result.count - 1][1] = max(result.last![1], iv[1])
        } else {
            result.append(iv)
        }
    }
    return result
}
