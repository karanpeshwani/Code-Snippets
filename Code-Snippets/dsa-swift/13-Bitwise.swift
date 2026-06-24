//
//  13-Bitwise.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - XOR Properties
// XOR = Exclusively OR → result is 1 only when inputs differ

// x ^ x  = 0        (same number cancels out)
// x ^ 0  = x        (zero is identity)
// x ^ y  = y ^ x    (commutative)
// (x^y)^z = x^(y^z) (associative)

let xorSame:  Int = 5 ^ 5   // 0
let xorZero:  Int = 5 ^ 0   // 5
let xorSwap1: Int = 3 ^ 6   // 5
let xorSwap2: Int = xorSwap1 ^ 6  // back to 3

// MARK: - AND Properties

// x & x  = x
// x & 0  = 0
// x & 1  = last bit of x (0 or 1)

// MARK: - OR Properties

// x | x  = x
// x | 0  = x

// MARK: - Shift Operators

// Left shift  << n  →  multiply by 2^n
let ls1 = 1 << 3    // 1 × 8  = 8
let ls2 = 3 << 2    // 3 × 4  = 12

// Right shift >> n  →  integer divide by 2^n  (arithmetic shift for signed Int)
let rs1 = 8 >> 1    // 8 / 2  = 4
let rs2 = 1 >> 4    // 1 / 16 = 0

// MARK: - Bit Manipulation Toolkit

// ── Check if bit i is set ────────────────────────────────────────────────────
func isBitSet(_ n: Int, _ i: Int) -> Bool { (n >> i) & 1 == 1 }

// ── Set bit i ────────────────────────────────────────────────────────────────
func setBit(_ n: Int, _ i: Int) -> Int { n | (1 << i) }

// ── Clear bit i ──────────────────────────────────────────────────────────────
func clearBit(_ n: Int, _ i: Int) -> Int { n & ~(1 << i) }

// ── Toggle bit i ─────────────────────────────────────────────────────────────
func toggleBit(_ n: Int, _ i: Int) -> Int { n ^ (1 << i) }

// ── Get lowest set bit ────────────────────────────────────────────────────────
// e.g. n = 0b1100 → 0b0100
func lowestSetBit(_ n: Int) -> Int { n & (-n) }

// ── Clear lowest set bit ─────────────────────────────────────────────────────
// e.g. n = 0b1100 → 0b1000
func clearLowestBit(_ n: Int) -> Int { n & (n - 1) }

// ── Update bit i to value v (0 or 1) ─────────────────────────────────────────
func updateBit(_ n: Int, _ i: Int, _ v: Int) -> Int {
    return (n & ~(1 << i)) | (v << i)
}

// MARK: - Count Set Bits (Popcount)

// Brian Kernighan's Algorithm   O(set bits)
func countBits(_ n: Int) -> Int {
    var n = n, count = 0
    while n != 0 { n &= n - 1; count += 1 }
    return count
}

// Built-in (Swift / platform)
// n.nonzeroBitCount   → Int   O(1) on most platforms

// DP approach: count bits for 0...n in O(n)
func countBitsDP(_ n: Int) -> [Int] {
    var dp = Array(repeating: 0, count: n + 1)
    for i in 1...n {
        dp[i] = dp[i >> 1] + (i & 1)   // dp[i] = dp[i/2] + last bit
    }
    return dp
}

// MARK: - Power of 2 Check

func isPowerOfTwo(_ n: Int) -> Bool { n > 0 && (n & (n - 1)) == 0 }
// 8 = 0b1000, 7 = 0b0111 → 8 & 7 = 0

// MARK: - Power of 4 Check

func isPowerOfFour(_ n: Int) -> Bool {
    // Power of 2 AND set bit is in an even position (0, 2, 4, …)
    return n > 0 && (n & (n-1)) == 0 && (n & 0x55555555) != 0
    // 0x55555555 = 0101...0101 in binary (bits at even positions)
}

// MARK: - Swap Without Temp Variable

func swapBits(_ a: inout Int, _ b: inout Int) {
    a ^= b
    b ^= a   // b = original a
    a ^= b   // a = original b
    // Note: don't use if a and b refer to the same location
}

// MARK: - Reverse Bits of a 32-bit Integer

func reverseBits(_ n: UInt32) -> UInt32 {
    var n = n, result: UInt32 = 0
    for _ in 0..<32 {
        result = (result << 1) | (n & 1)
        n >>= 1
    }
    return result
}

// MARK: - Algorithm: Single Number (LC 136)   O(n)
// Every element appears twice except one → XOR all

func singleNumber(_ nums: [Int]) -> Int {
    return nums.reduce(0, ^)
    // pairs cancel (x^x=0), single remains (x^0=x)
}

// MARK: - Algorithm: Single Number II (LC 137)   O(n)
// Every element appears 3 times except one

func singleNumberII(_ nums: [Int]) -> Int {
    var ones = 0, twos = 0
    for n in nums {
        ones = (ones ^ n) & ~twos
        twos = (twos ^ n) & ~ones
    }
    return ones
}

// MARK: - Algorithm: Two Non-Repeating Numbers (LC 260)   O(n)
// Two numbers appear once, all others twice

func singleNumberIII(_ nums: [Int]) -> [Int] {
    let xor = nums.reduce(0, ^)           // xor of the two unique numbers
    let diffBit = xor & (-xor)            // lowest set bit that differs between them
    var a = 0
    for n in nums where (n & diffBit) != 0 { a ^= n }
    return [a, xor ^ a]
}

// MARK: - Algorithm: Missing Number (LC 268)   O(n)
// Array contains [0, n] with one number missing

func missingNumber(_ nums: [Int]) -> Int {
    let n = nums.count
    let expected = n * (n + 1) / 2      // sum formula
    return expected - nums.reduce(0, +)
    // Or XOR approach:
    // return (0...n).reduce(0, ^) ^ nums.reduce(0, ^)
}

// MARK: - Algorithm: Hamming Distance (LC 461)

func hammingDistance(_ x: Int, _ y: Int) -> Int {
    return countBits(x ^ y)   // count set bits in XOR
}

// MARK: - Algorithm: Sum of Two Integers Without +/- (LC 371)

func getSum(_ a: Int, _ b: Int) -> Int {
    var a = a, b = b
    while b != 0 {
        let carry = a & b          // bits that cause carry
        a = a ^ b                  // sum without carry
        b = carry << 1             // shift carry left
    }
    return a
}

// MARK: - Algorithm: Subsets using Bitmask   O(2^n × n)

func subsets(_ nums: [Int]) -> [[Int]] {
    let n = nums.count
    var result = [[Int]]()
    for mask in 0..<(1 << n) {       // iterate all 2^n bitmasks
        var subset = [Int]()
        for i in 0..<n where (mask >> i) & 1 == 1 {
            subset.append(nums[i])
        }
        result.append(subset)
    }
    return result
}

// MARK: - Algorithm: Maximum XOR of Two Numbers (LC 421)   O(n)
// Greedy bit-by-bit from MSB using prefix set

func findMaximumXOR(_ nums: [Int]) -> Int {
    var maxXor = 0, mask = 0
    for i in stride(from: 31, through: 0, by: -1) {
        mask |= (1 << i)
        var prefixes = Set<Int>()
        for n in nums { prefixes.insert(n & mask) }
        let candidate = maxXor | (1 << i)
        for prefix in prefixes where prefixes.contains(candidate ^ prefix) {
            maxXor = candidate; break
        }
    }
    return maxXor
}

// MARK: - Bit Tricks Cheat Sheet
//
//  Expression            Meaning
//  n & 1                 check if n is odd
//  n >> 1                divide by 2 (integer)
//  n << 1                multiply by 2
//  n & (n-1)             clear lowest set bit
//  n & (-n)              isolate lowest set bit
//  n | (1<<i)            set bit i
//  n & ~(1<<i)           clear bit i
//  n ^ (1<<i)            toggle bit i
//  (n >> i) & 1          check bit i
//  x ^ x = 0             self-cancellation
//  x ^ 0 = x             XOR identity
//  ~n + 1                two's complement (= -n)
//  (a+b)/2               → a + (b-a)/2   (avoids overflow)
//  a + (b-a)/2           → safe midpoint (same as lo + (hi-lo)/2)
