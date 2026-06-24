//
//  05-Stack.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Stack — Generic Implementation
// LIFO: Last In, First Out
// All core operations O(1)

struct Stack<T> {
    private var storage = [T]()

    var isEmpty: Bool   { storage.isEmpty }
    var count: Int      { storage.count }
    var peek: T?        { storage.last }       // top element, no removal

    mutating func push(_ element: T) {
        storage.append(element)
    }

    @discardableResult
    mutating func pop() -> T? {
        return storage.popLast()
    }

    mutating func clear() {
        storage.removeAll()
    }
}

// MARK: - Using Array Directly as Stack
// append / removeLast / last  →  push / pop / peek

var rawStack = [Int]()
rawStack.append(1)          // push
rawStack.append(2)
rawStack.append(3)
rawStack.last               // → 3   peek   O(1)
rawStack.removeLast()       // → 3   pop    O(1)
rawStack.isEmpty            // → Bool

// MARK: - Pattern: Balanced Parentheses

func isBalanced(_ s: String) -> Bool {
    var stack = [Character]()
    let open:  Set<Character> = ["(", "[", "{"]
    let close: Set<Character> = [")", "]", "}"]
    let match: [Character: Character] = [")": "(", "]": "[", "}": "{"]

    for ch in s {
        if open.contains(ch) {
            stack.append(ch)
        } else if close.contains(ch) {
            if stack.isEmpty || stack.last != match[ch] { return false }
            stack.removeLast()
        }
    }
    return stack.isEmpty
}

// MARK: - Pattern: Monotonic Increasing Stack
// "Next Greater Element" — for each element, find the next element larger than it
// O(n) — each element pushed/popped at most once

func nextGreaterElement(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack  = [Int]()   // stores indices

    for i in 0..<nums.count {
        // pop all indices whose element is smaller than nums[i]
        while let top = stack.last, nums[top] < nums[i] {
            result[stack.removeLast()] = nums[i]
        }
        stack.append(i)
    }
    return result   // remaining indices have no greater element → -1
}

// Next Greater Element II — circular array
func nextGreaterElementCircular(_ nums: [Int]) -> [Int] {
    let n = nums.count
    var result = Array(repeating: -1, count: n)
    var stack  = [Int]()

    for i in 0..<(2 * n) {
        let idx = i % n
        while let top = stack.last, nums[top] < nums[idx] {
            result[stack.removeLast()] = nums[idx]
        }
        if i < n { stack.append(i) }
    }
    return result
}

// MARK: - Pattern: Monotonic Decreasing Stack
// "Next Smaller Element"

func nextSmallerElement(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack  = [Int]()

    for i in 0..<nums.count {
        while let top = stack.last, nums[top] > nums[i] {
            result[stack.removeLast()] = nums[i]
        }
        stack.append(i)
    }
    return result
}

// MARK: - Pattern: Min Stack — O(1) getMin

struct MinStack {
    private var stack    = [Int]()
    private var minStack = [Int]()   // parallel stack tracking running minimum

    mutating func push(_ val: Int) {
        stack.append(val)
        let currentMin = minStack.last.map { min($0, val) } ?? val
        minStack.append(currentMin)
    }

    mutating func pop() {
        stack.removeLast()
        minStack.removeLast()
    }

    func top() -> Int? { stack.last }
    func getMin() -> Int? { minStack.last }   // O(1)
}

// MARK: - Pattern: Daily Temperatures (LC 739)
// For each day, find how many days until a warmer temperature

func dailyTemperatures(_ temps: [Int]) -> [Int] {
    var result = Array(repeating: 0, count: temps.count)
    var stack  = [Int]()   // indices of days waiting for warmer day

    for i in 0..<temps.count {
        while let top = stack.last, temps[top] < temps[i] {
            let idx = stack.removeLast()
            result[idx] = i - idx
        }
        stack.append(i)
    }
    return result
}

// MARK: - Pattern: Largest Rectangle in Histogram (LC 84)   O(n)

func largestRectangleInHistogram(_ heights: [Int]) -> Int {
    var stack = [Int]()
    var maxArea = 0
    let bars = heights + [0]   // sentinel 0 to flush stack at end

    for (i, h) in bars.enumerated() {
        while let top = stack.last, bars[top] > h {
            let height = bars[stack.removeLast()]
            let width  = stack.isEmpty ? i : i - stack.last! - 1
            maxArea = max(maxArea, height * width)
        }
        stack.append(i)
    }
    return maxArea
}

// MARK: - Pattern: Valid Stack Sequences (LC 946)

func validateStackSequences(_ pushed: [Int], _ popped: [Int]) -> Bool {
    var stack = [Int]()
    var popIdx = 0

    for val in pushed {
        stack.append(val)
        while !stack.isEmpty && stack.last == popped[popIdx] {
            stack.removeLast()
            popIdx += 1
        }
    }
    return stack.isEmpty
}

// MARK: - Pattern: Decode String (LC 394)
// "3[a2[c]]" → "accaccacc"

func decodeString(_ s: String) -> String {
    var countStack = [Int]()
    var strStack   = [String]()
    var current    = ""
    var k = 0

    for ch in s {
        if let digit = ch.wholeNumberValue {
            k = k * 10 + digit
        } else if ch == "[" {
            countStack.append(k)
            strStack.append(current)
            current = ""
            k = 0
        } else if ch == "]" {
            let repeat_ = countStack.removeLast()
            let prev    = strStack.removeLast()
            current = prev + String(repeating: current, count: repeat_)
        } else {
            current.append(ch)
        }
    }
    return current
}
