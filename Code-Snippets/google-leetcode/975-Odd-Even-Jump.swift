//Again
// 975. Odd Even Jump
// https://leetcode.com/problems/odd-even-jump
//
// Time Complexity: O(N log N), where N is the length of the array.
// Sorting the indices based on values takes O(N log N) time.
// Building the next jump arrays using a monotonic stack takes O(N) time.
// The dynamic programming step takes O(N) time. Overall time complexity is dominated by sorting.
// Space Complexity: O(N) for storing the sorted indices, monotonic stack, next jump arrays, and DP arrays.

class Solution {
    func oddEvenJumps(_ arr: [Int]) -> Int {
        let n = arr.count
        let nextJustGreaterIndex = findNextJustGreaterIndex(arr.enumerated().sorted { $0.1 < $1.1 })
        let nextJustSmallerIndex = findNextJustGreaterIndex(arr.enumerated().sorted { $0.1 > $1.1 })

        var oddJumpGood: [Bool] = [Bool](repeating: false, count: n)
        var evenJumpGood: [Bool] = [Bool](repeating: false, count: n)

        //Base conditions
        oddJumpGood[n - 1] = true
        evenJumpGood[n - 1] = true

        for i in (0..<n-1).reversed() {
            let nextGreaterIndex = nextJustGreaterIndex[i]
            let nextSmallerIndex = nextJustSmallerIndex[i]

            if nextGreaterIndex != -1 {
                oddJumpGood[i] = evenJumpGood[nextGreaterIndex]
            }

            if nextSmallerIndex != -1 {
                evenJumpGood[i] = oddJumpGood[nextSmallerIndex]
            }
        }

        var result: Int = 0

        for boolean in oddJumpGood {
            if boolean {
                result += 1
            }
        }

        return result
    }

    private func findNextJustGreaterIndex(_ arr: [EnumeratedSequence<[Int]>.Iterator.Element]) -> [Int] {
        var result: [Int] = [Int](repeating: -1, count: arr.count)
        var stack: [Int] = []

        for (index, _) in arr {
            while !stack.isEmpty && stack.last! < index {
                result[stack.popLast()!] = index
            }
            stack.append(index)
        }

        return result
    }
}
