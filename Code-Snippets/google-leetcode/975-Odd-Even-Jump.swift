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
        if n <= 1 { return n }
        
        // Arrays to store the next index to jump to for odd and even jumps
        var oddNext = [Int?](repeating: nil, count: n)
        var evenNext = [Int?](repeating: nil, count: n)
        
        // Create an array of indices
        let indices = Array(0..<n)
        
        // Sort indices for odd jumps: values ascending, indices ascending
        let oddSortedIndices = indices.sorted {
            if arr[$0] != arr[$1] {
                return arr[$0] < arr[$1]
            }
            return $0 < $1
        }
        
        // Monotonic stack to find the next valid index (which appears after current index)
        var stack = [Int]()
        for i in oddSortedIndices {
            while !stack.isEmpty && stack.last! < i {
                oddNext[stack.removeLast()] = i
            }
            stack.append(i)
        }
        
        // Sort indices for even jumps: values descending, indices ascending
        let evenSortedIndices = indices.sorted {
            if arr[$0] != arr[$1] {
                return arr[$0] > arr[$1]
            }
            return $0 < $1
        }
        
        // Monotonic stack to find the next valid index
        stack.removeAll()
        for i in evenSortedIndices {
            while !stack.isEmpty && stack.last! < i {
                evenNext[stack.removeLast()] = i
            }
            stack.append(i)
        }
        
        // DP arrays to store if we can reach the end using odd/even jump from index i
        var higher = [Bool](repeating: false, count: n)
        var lower = [Bool](repeating: false, count: n)
        
        // Base case: we can always reach the end from the last element
        higher[n - 1] = true
        lower[n - 1] = true
        var goodIndicesCount = 1
        
        // Iterate backwards from the second to last element
        for i in stride(from: n - 2, through: 0, by: -1) {
            if let nextOdd = oddNext[i] {
                higher[i] = lower[nextOdd]
            }
            if let nextEven = evenNext[i] {
                lower[i] = higher[nextEven]
            }
            if higher[i] {
                goodIndicesCount += 1
            }
        }
        
        return goodIndicesCount
    }
}
