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
    // Note: Heap in swift-collections is a Min-Heap by default.
    // We insert negated values into maxHeap to simulate a Max-Heap behavior.
    private var maxHeap = Heap<Int>()
    
    // minHeap stores the larger half of the numbers.
    private var minHeap = Heap<Int>()
    
    init() {}
    
    func addNum(_ num: Int) {
        maxHeap.insert(-num)
        
        // Ensure every element in maxHeap is less than or equal to elements in minHeap
        if let maxTop = maxHeap.min, let minTop = minHeap.min {
            if -maxTop > minTop {
                minHeap.insert(-maxHeap.removeMin())
            }
        }
        
        // Balance sizes: maxHeap can have at most one more element than minHeap
        if maxHeap.count > minHeap.count + 1 {
            minHeap.insert(-maxHeap.removeMin())
        } else if minHeap.count > maxHeap.count {
            maxHeap.insert(-minHeap.removeMin())
        }
    }
    
    func findMedian() -> Double {
        if maxHeap.count > minHeap.count {
            return Double(-maxHeap.min!)
        } else {
            return (Double(-maxHeap.min!) + Double(minHeap.min!)) / 2.0
        }
    }
}
