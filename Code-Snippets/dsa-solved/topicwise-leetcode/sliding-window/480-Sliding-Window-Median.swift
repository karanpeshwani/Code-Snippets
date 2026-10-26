// 480. Sliding Window Median
// https://leetcode.com/problems/sliding-window-median/

/*
 Intuition:
 To find the median of a sliding window, we can maintain two heaps:
 1. A max-heap to store the smaller half of the numbers.
 2. A min-heap to store the larger half of the numbers.
 The median is either the max element in the smaller half (if odd window) or the average of the two midpoints (if even).
 Since removing arbitrary elements from a heap is inefficient (O(N)), we use "lazy deletion".
 We keep a dictionary to record elements that have exited the sliding window. We only physically remove these "invalid"
 elements when they reach the top of either heap. This maintains the heap properties efficiently.

 Time Complexity: O(N log K)
 - N is the number of elements in `nums`.
 - Each element is added and removed at most once from the heaps.
 - Heap operations take O(log K) amortized time due to lazy deletion.
 - Overall time complexity is O(N log K).

 Space Complexity: O(K)
 - The heaps can store at most K elements plus lazily deleted elements.
 - The dictionary for lazy deletion stores at most K elements.
 - Overall space complexity is O(K).
 */

import Collections

class Solution {
    func medianSlidingWindow(_ nums: [Int], _ k: Int) -> [Double] {
        var minHeap = Heap<Int>()
        var maxHeap = Heap<Int>()
        var invalidCounts = [Int: Int]()
        var result = [Double]()
        
        // Track the valid sizes of heaps independently of lazily deleted elements
        var maxHeapValidSize = 0
        var minHeapValidSize = 0
        
        for i in 0..<nums.count {
            let num = nums[i]
            
            // Add new element to maxHeap (smaller half)
            if maxHeapValidSize == 0 || num <= maxHeap.max! {
                maxHeap.insert(num)
                maxHeapValidSize += 1
            } else {
                minHeap.insert(num)
                minHeapValidSize += 1
            }
            
            // Record out of window element for lazy deletion
            if i >= k {
                let outNum = nums[i - k]
                invalidCounts[outNum, default: 0] += 1
                
                // Update valid sizes
                if outNum <= maxHeap.max! {
                    maxHeapValidSize -= 1
                } else {
                    minHeapValidSize -= 1
                }
            }
            
            // Rebalance the valid sizes of the heaps
            while maxHeapValidSize > minHeapValidSize + 1 {
                let val = maxHeap.popMax()!
                minHeap.insert(val)
                maxHeapValidSize -= 1
                minHeapValidSize += 1
            }
            while minHeapValidSize > maxHeapValidSize {
                let val = minHeap.popMin()!
                maxHeap.insert(val)
                minHeapValidSize -= 1
                maxHeapValidSize += 1
            }
            
            // Clean up invalid tops (Lazy Deletion)
            while let maxTop = maxHeap.max, (invalidCounts[maxTop] ?? 0) > 0 {
                invalidCounts[maxTop]! -= 1
                maxHeap.popMax()
            }
            while let minTop = minHeap.min, (invalidCounts[minTop] ?? 0) > 0 {
                invalidCounts[minTop]! -= 1
                minHeap.popMin()
            }
            
            // Record median when the window is fully formed
            if i >= k - 1 {
                if k % 2 == 1 {
                    result.append(Double(maxHeap.max!))
                } else {
                    result.append((Double(maxHeap.max!) + Double(minHeap.min!)) / 2.0)
                }
            }
        }
        
        return result
    }
}
