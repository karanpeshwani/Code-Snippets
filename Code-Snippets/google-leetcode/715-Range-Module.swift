//Again -> Segment Tree
// 715. Range Module
// https://leetcode.com/problems/range-module
//
// Time Complexity: O(N) worst-case per query/add/remove, but O(log N) for pure queries.
//   - Here, N is the number of disjoint intervals (up to 10^4). 
//   - Searching for the overlapping ranges takes O(log N) using binary search.
//   - Modifying the array takes O(N) due to shifting elements. However, arrays in Swift are backed 
//     by contiguous memory, making `replaceSubrange` utilize `memmove`, which is extremely fast 
//     for N = 10,000, achieving optimal real-world performance compared to complex trees.
// Space Complexity: O(N)
//   - N is the number of disjoint ranges. The array stores at most O(N) intervals.

class RangeModule {
    
    struct Interval {
        var left: Int
        var right: Int
    }
    
    // Ordered list of disjoint intervals
    private var intervals = [Interval]()

    init() {
        // Initialized empty
    }
    
    func addRange(_ left: Int, _ right: Int) {
        var left = left
        var right = right
        
        // Find indices of intervals that need to be merged
        let startIdx = lowerBoundRight(left) // first interval with right >= left
        let endIdx = upperBoundLeft(right)   // first interval with left > right
        
        if startIdx < endIdx {
            left = min(left, intervals[startIdx].left)
            right = max(right, intervals[endIdx - 1].right)
            intervals.replaceSubrange(startIdx..<endIdx, with: [Interval(left: left, right: right)])
        } else {
            intervals.insert(Interval(left: left, right: right), at: startIdx)
        }
    }
    
    func queryRange(_ left: Int, _ right: Int) -> Bool {
        let idx = upperBoundLeft(left)
        // If there's an interval covering left, it must be exactly before the first interval where left > left
        if idx > 0 {
            let interval = intervals[idx - 1]
            if interval.left <= left && interval.right >= right {
                return true
            }
        }
        return false
    }
    
    func removeRange(_ left: Int, _ right: Int) {
        let startIdx = upperBoundRight(left) // first interval with right > left
        let endIdx = lowerBoundLeft(right)   // first interval with left >= right
        
        guard startIdx < endIdx else { return }
        
        var newIntervals = [Interval]()
        
        let first = intervals[startIdx]
        if first.left < left {
            newIntervals.append(Interval(left: first.left, right: left))
        }
        
        let last = intervals[endIdx - 1]
        if last.right > right {
            newIntervals.append(Interval(left: right, right: last.right))
        }
        
        intervals.replaceSubrange(startIdx..<endIdx, with: newIntervals)
    }
    
    // MARK: - Binary Search Helpers
    
    // First index where interval.right >= target
    private func lowerBoundRight(_ target: Int) -> Int {
        var low = 0
        var high = intervals.count
        while low < high {
            let mid = low + (high - low) / 2
            if intervals[mid].right >= target {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    // First index where interval.right > target
    private func upperBoundRight(_ target: Int) -> Int {
        var low = 0
        var high = intervals.count
        while low < high {
            let mid = low + (high - low) / 2
            if intervals[mid].right > target {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
    
    // First index where interval.left >= target
    private func lowerBoundLeft(_ target: Int) -> Int {
        var low = 0
        var high = intervals.count
        while low < high {
            let mid = low + (high - low) / 2
            if intervals[mid].left >= target {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    // First index where interval.left > target
    private func upperBoundLeft(_ target: Int) -> Int {
        var low = 0
        var high = intervals.count
        while low < high {
            let mid = low + (high - low) / 2
            if intervals[mid].left > target {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
