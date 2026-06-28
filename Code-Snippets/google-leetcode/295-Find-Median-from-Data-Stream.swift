// 295. Find Median from Data Stream
// Link: https://leetcode.com/problems/find-median-from-data-stream/
//
// Time Complexity: O(log N) for addNum, O(1) for findMedian.
// Explanation: Adding a number takes logarithmic time as we insert and extract from a heap. Finding the median is a constant time lookup of the roots of the heaps.
// Space Complexity: O(N)
// Explanation: The two heaps store all N elements from the data stream.

import Collections

class MedianFinder {
    // maxHeap stores the smaller half of the numbers.
    // Swift's Heap is inherently a Min-Max Heap, allowing direct access to the maximum element.
    private var maxHeap = Heap<Int>()

    // minHeap stores the larger half of the numbers.
    private var minHeap = Heap<Int>()

    init() {}

    func addNum(_ num: Int) {
        // 1. Add the new number to the maxHeap (smaller half)
        maxHeap.insert(num)

        // 2. Guarantee that maxHeap elements are <= minHeap elements
        // by pushing the largest element of the smaller half into the larger half
        minHeap.insert(maxHeap.removeMax())

        // 3. Balance sizes: maxHeap should hold the extra element if the total count is odd
        if minHeap.count > maxHeap.count {
            maxHeap.insert(minHeap.removeMin())
        }
    }

    func findMedian() -> Double {
        if maxHeap.count > minHeap.count {
            return Double(maxHeap.max!)
        } else {
            return (Double(maxHeap.max!) + Double(minHeap.min!)) / 2.0
        }
    }
}
