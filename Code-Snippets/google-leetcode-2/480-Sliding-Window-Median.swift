// 480. Sliding Window Median
// https://leetcode.com/problems/sliding-window-median

/*
 Intuition:
 To find the median of a sliding window, we can maintain two heaps:
 1. A max-heap for the smaller half of the window's elements.
 2. A min-heap for the larger half of the window's elements.
 The median can be quickly found by looking at the tops of the heaps.
 Since we need to remove elements that fall out of the sliding window, and finding/removing
 an arbitrary element in a heap is O(N), we can use "lazy deletion". We keep a hash map
 of the elements to be removed and their counts. When an element at the top of a heap is
 marked for removal, we pop it.
 
 Time Complexity: O(N log K)
 - Inserting an element into a heap takes O(log K).
 - Lazy deletion ensures we only pay O(log K) when we actually pop an element.
 - Overall, for N elements, it takes O(N log K) time.
 
 Space Complexity: O(N)
 - The heaps store up to N elements (if we don't prune aggressively).
 - The hash map for delayed removals can store up to N elements in the worst case.
 - Overall space complexity is O(N).
 */

import Collections

class Solution {
    func medianSlidingWindow(_ nums: [Int], _ k: Int) -> [Double] {
        var minHeap = Heap<Int>() // Stores larger half
        var maxHeap = Heap<Int>(sort: >) // Stores smaller half
        var delayed = [Int: Int]()
        var result = [Double]()
        
        var minHeapSize = 0
        var maxHeapSize = 0
        
        func balance() {
            if maxHeapSize > minHeapSize + 1 {
                minHeap.insert(maxHeap.popMax()!)
                maxHeapSize -= 1
                minHeapSize += 1
                pruneMaxHeap()
            } else if minHeapSize > maxHeapSize {
                maxHeap.insert(minHeap.popMin()!)
                minHeapSize -= 1
                maxHeapSize += 1
                pruneMinHeap()
            }
        }
        
        func pruneMinHeap() {
            while let top = minHeap.min, delayed[top, default: 0] > 0 {
                delayed[top]! -= 1
                minHeap.popMin()
            }
        }
        
        func pruneMaxHeap() {
            while let top = maxHeap.max, delayed[top, default: 0] > 0 {
                delayed[top]! -= 1
                maxHeap.popMax()
            }
        }
        
        for i in 0..<nums.count {
            let num = nums[i]
            
            // Insert new element
            if maxHeapSize == 0 || num <= (maxHeap.max ?? Int.max) {
                maxHeap.insert(num)
                maxHeapSize += 1
            } else {
                minHeap.insert(num)
                minHeapSize += 1
            }
            
            // Remove element that falls out of window
            if i >= k {
                let outNum = nums[i - k]
                delayed[outNum, default: 0] += 1
                if outNum <= (maxHeap.max ?? Int.max) {
                    maxHeapSize -= 1
                    if outNum == maxHeap.max { pruneMaxHeap() }
                } else {
                    minHeapSize -= 1
                    if outNum == minHeap.min { pruneMinHeap() }
                }
            }
            
            balance()
            
            // Add median to result
            if i >= k - 1 {
                if k % 2 == 1 {
                    result.append(Double(maxHeap.max!))
                } else {
                    let median = (Double(maxHeap.max!) + Double(minHeap.min!)) / 2.0
                    result.append(median)
                }
            }
        }
        
        return result
    }
}
