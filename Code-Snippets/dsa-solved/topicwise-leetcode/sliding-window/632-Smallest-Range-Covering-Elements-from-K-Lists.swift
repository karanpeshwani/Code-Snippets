// 632. Smallest Range Covering Elements from K Lists
// https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/

/*
 Intuition:
 We need to find the smallest range that includes at least one number from each of the `k` lists.
 We can use a Min-Heap to keep track of the minimum element among the currently considered elements from all `k` lists.
 We also maintain the `currentMax` element among these `k` elements.
 The current range is `[minHeap.min, currentMax]`.
 To potentially find a smaller range, we extract the minimum element from the heap, update our best range if the current one is smaller,
 and then insert the next element from the same list that the extracted minimum element belonged to.
 If any list is exhausted, we cannot form a valid range anymore, so we stop.

 Time Complexity: O(N log K)
 - N is the total number of elements across all `k` lists.
 - We initially push `k` elements into the heap, taking O(K log K).
 - Then, we process each of the remaining elements. Each pop and push operation on the min-heap of size `K` takes O(log K).
 - In the worst case, we process all N elements, so it takes O(N log K) time.

 Space Complexity: O(K)
 - The min-heap always stores exactly `k` elements (one from each list).
 - Overall space complexity is O(K).
 */

import Collections

class Solution {
    struct Element: Comparable {
        let value: Int
        let listIndex: Int
        let itemIndex: Int
        
        static func < (lhs: Element, rhs: Element) -> Bool {
            return lhs.value < rhs.value
        }
    }
    
    func smallestRange(_ nums: [[Int]]) -> [Int] {
        var minHeap = Heap<Element>()
        var currentMax = Int.min
        
        // Initialize the heap with the first element of each list
        for i in 0..<nums.count {
            let val = nums[i][0]
            minHeap.insert(Element(value: val, listIndex: i, itemIndex: 0))
            currentMax = max(currentMax, val)
        }
        
        var bestRange = [0, Int.max]
        
        while let minElement = minHeap.popMin() {
            let currentMin = minElement.value
            
            // Update the best range if the current one is strictly smaller or same length but starts earlier
            if (currentMax - currentMin < bestRange[1] - bestRange[0]) || 
               (currentMax - currentMin == bestRange[1] - bestRange[0] && currentMin < bestRange[0]) {
                bestRange = [currentMin, currentMax]
            }
            
            // Try to add the next element from the same list
            let nextItemIndex = minElement.itemIndex + 1
            if nextItemIndex < nums[minElement.listIndex].count {
                let nextVal = nums[minElement.listIndex][nextItemIndex]
                minHeap.insert(Element(value: nextVal, listIndex: minElement.listIndex, itemIndex: nextItemIndex))
                currentMax = max(currentMax, nextVal)
            } else {
                // If any list is exhausted, we can't cover all lists anymore
                break
            }
        }
        
        return bestRange
    }
}
