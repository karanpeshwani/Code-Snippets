//
//  02-String.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Creation

var str = "Hello, World!"
let empty      = ""
let fromChar   = String(Character("A"))                   // "A"
let fromInt    = String(42)                               // "42"
let fromFmt    = String(format: "%.2f", 3.14)             // "3.14"
let repeated   = String(repeating: "ab", count: 3)        // "ababab"
let fromChars  = String(["H","e","l","l","o"] as [Character]) // "Hello"

// MARK: - Basic Properties

// str.count         → Int     O(n) — Swift counts Unicode scalars
// str.isEmpty       → Bool
// str.startIndex    → String.Index
// str.endIndex      → String.Index  (one past last character)

// MARK: - Index Mechanics
// Swift String indices are NOT integers — must use String.Index

let s = "Hello"
let i0 = s.startIndex                               // → 'H'
let i1 = s.index(s.startIndex, offsetBy: 1)        // → 'e'
let i4 = s.index(s.endIndex,   offsetBy: -1)       // → 'o'

// s[i0]            → Character 'H'
// s[i1]            → Character 'e'
// s.distance(from: s.startIndex, to: s.endIndex)   → Int 5

// Advance index safely (won't go past endIndex)
func advanceIndex(_ s: String, _ idx: String.Index, by n: Int) -> String.Index? {
    return s.index(idx, offsetBy: n, limitedBy: s.endIndex)
}

// Get character at integer offset (convenience)
func charAt(_ s: String, _ offset: Int) -> Character {
    return s[s.index(s.startIndex, offsetBy: offset)]
}

// MARK: - Substring

let hello = "Hello, Swift"

// prefix / suffix (return Substring)
let first5 = hello.prefix(5)                        // "Hello"
let last5  = hello.suffix(5)                        // "Swift"
String(first5)                                       // → String

// Range-based substring
let sStart = hello.startIndex
let sEnd   = hello.index(sStart, offsetBy: 5)
let sub: Substring = hello[sStart..<sEnd]           // "Hello"
let asString = String(sub)                           // convert to String

// MARK: - Mutation

var m = "Hello"
m.append("!")                                        // "Hello!"
m.append(contentsOf: " World")                      // "Hello! World"

let atIdx = m.index(m.startIndex, offsetBy: 5)
m.insert("X", at: atIdx)                            // insert char
m.insert(contentsOf: "AB", at: m.startIndex)        // insert string

// Remove at index → returns removed Character
// m.remove(at: m.startIndex)
// m.removeSubrange(range)

// MARK: - Search

let text = "swift is great"

// text.contains("swift")                           → Bool
// text.hasPrefix("swift")                          → Bool
// text.hasSuffix("great")                          → Bool
// text.firstIndex(of: "i")                         → String.Index?
// text.lastIndex(of: "t")                          → String.Index?
// text.range(of: "is")                             → Range<String.Index>?
// text.firstIndex { $0.isUppercase }               → String.Index?

// MARK: - Split & Trim

let csv = "  Karan, Diya , Bob  "

// components(separatedBy:)  → [String]  (Foundation)
let parts1 = csv.components(separatedBy: ",")       // ["  Karan", " Diya ", " Bob  "]

// split(separator:)         → [Substring]  (stdlib, ignores empty by default)
let parts2 = "a,,b,c".split(separator: ",")         // ["a", "b", "c"]
let parts3 = "a,,b,c".split(separator: ",", omittingEmptySubsequences: false) // ["a","","b","c"]

// Trim whitespace
let trimmed = csv.trimmingCharacters(in: .whitespaces)     // "Karan, Diya , Bob"
let trimmed2 = csv.trimmingCharacters(in: .whitespacesAndNewlines)

// Clean pipeline: trim + split + trim each word
let cleaned = csv
    .trimmingCharacters(in: .whitespaces)
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: .whitespaces) }        // ["Karan","Diya","Bob"]

// MARK: - Case

// "Hello".lowercased()    → "hello"
// "Hello".uppercased()    → "HELLO"

// MARK: - Conversion

let numStr = "42"
let intVal  = Int(numStr)           // → Int?   use optional binding safely
let intForce = Int(numStr)!         // → Int    crash if invalid

let num = 42
let strVal  = String(num)           // → "42"
let strInterp = "\(num)"            // → "42"

// Character ↔ ASCII
let ch: Character = "A"
let ascii = ch.asciiValue           // → UInt8?  65
let intASCII = Int(ascii!)          // → Int      65

// Reconstruct character from ASCII
let fromASCII = Character(UnicodeScalar(65))   // 'A'

// Common ASCII values (memorise for interviews):
// 'a' = 97,  'z' = 122
// 'A' = 65,  'Z' = 90
// '0' = 48,  '9' = 57

// Char offset from 'a'
let offset = Int(Character("c").asciiValue!) - Int(Character("a").asciiValue!)  // 2

// MARK: - Character Classification

// Character("A").isUppercase     → Bool
// Character("a").isLowercase     → Bool
// Character("3").isNumber        → Bool
// Character("3").isLetter        → Bool  (false)
// Character(" ").isWhitespace    → Bool
// Character("!").isPunctuation   → Bool

// MARK: - Working with [Character]

let word = "Hello"
let chars = Array(word)             // → [Character]   O(n)
// chars[0]                         → 'H'
// String(chars)                    → "Hello"

// Iterate
for ch2 in word { _ = ch2 }

// String as array of chars (common in interviews)
func reverseString(_ s: inout [Character]) {
    var lo = 0, hi = s.count - 1
    while lo < hi { s.swapAt(lo, hi); lo += 1; hi -= 1 }
}

// MARK: - Algorithm: Anagram Check   O(n)

func isAnagram(_ s: String, _ t: String) -> Bool {
    guard s.count == t.count else { return false }
    var freq = [Character: Int]()
    for ch in s { freq[ch, default: 0] += 1 }
    for ch in t {
        freq[ch, default: 0] -= 1
        if freq[ch]! < 0 { return false }
    }
    return true
}

// Alternative — sort & compare  O(n log n)
func isAnagramSort(_ s: String, _ t: String) -> Bool {
    return s.sorted() == t.sorted()
}

// MARK: - Algorithm: Palindrome Check — Two Pointer   O(n)

func isPalindrome(_ s: String) -> Bool {
    let chars = Array(s.lowercased().filter { $0.isLetter || $0.isNumber })
    var lo = 0, hi = chars.count - 1
    while lo < hi {
        if chars[lo] != chars[hi] { return false }
        lo += 1; hi -= 1
    }
    return true
}

// MARK: - Algorithm: Reverse Words   O(n)

func reverseWords(_ s: String) -> String {
    return s.split(separator: " ").reversed().joined(separator: " ")
}

// MARK: - Algorithm: Sliding Window — Longest Substring Without Repeating   O(n)

func longestUniqueSubstring(_ s: String) -> Int {
    let chars = Array(s)
    var seen = [Character: Int]()   // char → last seen index
    var lo = 0, best = 0
    for (hi, ch) in chars.enumerated() {
        if let prev = seen[ch], prev >= lo { lo = prev + 1 }
        seen[ch] = hi
        best = max(best, hi - lo + 1)
    }
    return best
}

// MARK: - Algorithm: Sliding Window — At Most K Distinct Characters   O(n)

func atMostKDistinct(_ s: String, _ k: Int) -> Int {
    let chars = Array(s)
    var freq = [Character: Int]()
    var lo = 0, best = 0
    for (hi, ch) in chars.enumerated() {
        freq[ch, default: 0] += 1
        while freq.count > k {
            let left = chars[lo]
            freq[left]! -= 1
            if freq[left]! == 0 { freq.removeValue(forKey: left) }
            lo += 1
        }
        best = max(best, hi - lo + 1)
    }
    return best
}

// MARK: - Algorithm: Character Frequency Map   O(n)

func charFrequency(_ s: String) -> [Character: Int] {
    s.reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }
}

// MARK: - Algorithm: Group Anagrams   O(n * k log k)

func groupAnagrams(_ strs: [String]) -> [[String]] {
    var map = [String: [String]]()
    for s in strs {
        let key = String(s.sorted())
        map[key, default: []].append(s)
    }
    return Array(map.values)
}

// MARK: - Tips
// • Use Array(s) to work with index-based access — avoids String.Index complexity
// • Use str.utf8 for byte-level problems (ASCII only)
// • String concatenation in a loop is O(n²) — build [Character] and join at end
// • s.hasPrefix / s.hasSuffix are O(k) where k = prefix/suffix length
