//
//  04-Dictionary.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// Note: (key: Key, value: Value) != Tuple
// Note: (key: Key, value: Value) == Dictionary<Key, Value>.Element

// MARK: - Creation

var dict: [String: Int] = ["apple": 1, "banana": 2, "cherry": 3]
var empty = [String: Int]()
var typed: Dictionary<String, Int> = [:]

// From arrays of keys & values
let keys   = ["a", "b", "c"]
let values = [1, 2, 3]
let fromZip = Dictionary(uniqueKeysWithValues: zip(keys, values))  // ["a":1,"b":2,"c":3]

// Grouping — frequency / classification
let words = ["cat", "car", "bat", "bar", "can"]
let grouped = Dictionary(grouping: words) { $0.first! }  // ["c":["cat","car","can"],"b":["bat","bar"]]

// MARK: - Access

// dict["apple"]              → Value?   returns nil if key absent  O(1) average
// dict["missing"]            → nil
// dict["apple", default: 0]  → Value   never nil  O(1) average

let val = dict["apple"] ?? 0         // safe access with fallback

// MARK: - Mutation

dict["date"] = 4                     // insert or update   O(1) average
dict["apple"] = 10                   // update
dict["apple"] = nil                  // delete (same as removeValue)

dict.removeValue(forKey: "banana")   // → Value?   O(1)
dict.removeAll()                     // → Void

dict = ["apple": 1, "banana": 2, "cherry": 3]

// MARK: - Default Value Idiom (key interview pattern)

var freq = [String: Int]()
let sentence = "hello world hello"
for word in sentence.split(separator: " ") {
    freq[String(word), default: 0] += 1     // increment without optional
}
// freq = ["hello": 2, "world": 1]

// MARK: - Properties

// dict.isEmpty          → Bool
// dict.count            → Int
// dict.count { (k, v) in v > 1 }     → Int   (Swift 5.9+)
// dict.keys             → [Key]      LazyMapCollection — use Array(dict.keys)
// dict.values           → [Value]    LazyMapCollection

let allKeys   = Array(dict.keys)     // → [String]
let allValues = Array(dict.values)   // → [Int]

// MARK: - Iteration

dict.forEach { key, value in
    _ = "\(key): \(value)"
}

for (key, value) in dict {
    _ = (key, value)
}

// Enumerated — gives offset, not meaningful order (dicts are unordered)
let enumerated = Array(dict.enumerated())  // [(offset: Int, element: (key: String, value: Int))]

// MARK: - Search

// dict.contains { (k, v) in v > 2 }   → Bool   O(n)

// MARK: - Filter & Transform

// dict.filter { (k, v) in v > 1 }     → [String: Int]   O(n)
// dict.mapValues { $0 * 2 }           → [String: Int]   O(n)
// dict.compactMapValues { Int($0) }   → [Key: NewVal]   O(n)  (for [String:String] → [String:Int])

// MARK: - Merge

var d1 = ["a": 1, "b": 2]
let d2 = ["b": 20, "c": 3]

// Keep existing value on conflict:
d1.merge(d2) { existing, _ in existing }    // → Void   {"a":1,"b":2,"c":3}

// Keep new value on conflict:
d1.merge(d2) { _, new in new }              // → Void   {"a":1,"b":20,"c":3}

// Non-mutating:
let merged = d1.merging(d2) { $1 }          // → [String: Int]

// MARK: - Sort

let sortedByKey   = dict.sorted { $0.key   < $1.key   }  // → [(key,value)]
let sortedByValue = dict.sorted { $0.value < $1.value }  // → [(key,value)]

// dict.max { $0.value < $1.value }   → (key: String, value: Int)?   O(n)
// dict.min { $0.value < $1.value }   → (key: String, value: Int)?   O(n)
// dict.randomElement()               → (key: String, value: Int)?

// MARK: - Patterns

// ── Two Sum   O(n) ───────────────────────────────────────────────────────────

func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen = [Int: Int]()          // value → index
    for (i, n) in nums.enumerated() {
        let complement = target - n
        if let j = seen[complement] { return [j, i] }
        seen[n] = i
    }
    return []
}

// ── Top K Frequent Elements   O(n log k) ────────────────────────────────────

func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    let freq = nums.reduce(into: [Int: Int]()) { $0[$1, default: 0] += 1 }
    return freq.sorted { $0.value > $1.value }.prefix(k).map { $0.key }
}

// ── Character Frequency (26-letter alphabet)  O(n) ───────────────────────────

func charFreqArray(_ s: String) -> [Int] {
    var freq = Array(repeating: 0, count: 26)
    for ch in s {
        freq[Int(ch.asciiValue!) - Int(Character("a").asciiValue!)] += 1
    }
    return freq
}

// ── Subarray Sum Equals K  O(n) ───────────────────────────────────────────────
// Count subarrays whose sum equals k using prefix sum + hash map

func subarraySum(_ nums: [Int], _ k: Int) -> Int {
    var prefixCount = [0: 1]    // prefixSum → frequency
    var sum = 0, count = 0
    for n in nums {
        sum += n
        count += prefixCount[sum - k, default: 0]
        prefixCount[sum, default: 0] += 1
    }
    return count
}

// ── Longest Subarray with Equal 0s and 1s   O(n) ─────────────────────────────
// Treat 0 as -1, find longest subarray with sum 0

func findMaxLengthEqualZeroOne(_ nums: [Int]) -> Int {
    var firstSeen = [0: -1]     // prefixSum → first index seen
    var sum = 0, best = 0
    for (i, n) in nums.enumerated() {
        sum += n == 0 ? -1 : 1
        if let prev = firstSeen[sum] {
            best = max(best, i - prev)
        } else {
            firstSeen[sum] = i
        }
    }
    return best
}

// ── Cache / Memoisation pattern ───────────────────────────────────────────────

func fibMemo(_ n: Int, _ memo: inout [Int: Int]) -> Int {
    if n <= 1 { return n }
    if let cached = memo[n] { return cached }
    let result = fibMemo(n - 1, &memo) + fibMemo(n - 2, &memo)
    memo[n] = result
    return result
}
