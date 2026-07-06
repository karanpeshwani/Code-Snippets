// 218. The Skyline Problem
// https://leetcode.com/problems/the-skyline-problem
//
// Intuition/Explanation:
// We can solve this by sweeping a vertical line from left to right.
// First, we extract all critical points (start and end x-coordinates) from the buildings.
// We represent a start edge with a negative height to distinguish it from an end edge, and to ensure
// that at the same x-coordinate, start edges are processed before end edges (and taller starts before shorter ones).
// We use a max-heap (or equivalent) to keep track of the active building heights.
// As we sweep, we add heights for start edges and remove heights for end edges.
// If the maximum active height changes after processing an x-coordinate, we have a new key point in the skyline.
// Since Swift doesn't have a built-in max-heap that allows O(log N) arbitrary deletion, we can use an array
// and maintain it in sorted order using binary search, which gives O(N) deletion, leading to O(N^2) overall.
// However, for typical LeetCode constraints, O(N^2) might pass, or we can use lazy deletion.
// Here we use an array with binary search insertion/deletion for simplicity and speed on small datasets.
//
// Time Complexity: O(N^2) worst case due to array insertion/deletion, where N is the number of buildings. 
// With a proper balanced BST or HashHeap, this would be O(N log N).
// Space Complexity: O(N) to store the edges and the active heights.

class Solution {
    func getSkyline(_ buildings: [[Int]]) -> [[Int]] {
        var edges = [[Int]]()
        
        for b in buildings {
            let left = b[0], right = b[1], height = b[2]
            // Start edge: negative height
            edges.append([left, -height])
            // End edge: positive height
            edges.append([right, height])
        }
        
        // Sort edges:
        // 1. By x-coordinate.
        // 2. If x is same, sort by height. 
        //    (Start edges before end edges, taller starts before shorter starts, shorter ends before taller ends)
        edges.sort { a, b in
            if a[0] != b[0] {
                return a[0] < b[0]
            }
            return a[1] < b[1]
        }
        
        var result = [[Int]]()
        var activeHeights = [0] // Starts with ground level
        var currentMaxHeight = 0
        
        for edge in edges {
            let x = edge[0]
            let h = edge[1]
            
            if h < 0 {
                // It's a start edge, add the absolute height. Keep array sorted.
                insertSorted(&activeHeights, -h)
            } else {
                // It's an end edge, remove the height.
                removeSorted(&activeHeights, h)
            }
            
            let newMaxHeight = activeHeights.last!
            
            if currentMaxHeight != newMaxHeight {
                result.append([x, newMaxHeight])
                currentMaxHeight = newMaxHeight
            }
        }
        
        return result
    }
    
    // Helper to insert into sorted array
    private func insertSorted(_ arr: inout [Int], _ val: Int) {
        var left = 0
        var right = arr.count
        while left < right {
            let mid = left + (right - left) / 2
            if arr[mid] < val {
                left = mid + 1
            } else {
                right = mid
            }
        }
        arr.insert(val, at: left)
    }
    
    // Helper to remove from sorted array
    private func removeSorted(_ arr: inout [Int], _ val: Int) {
        var left = 0
        var right = arr.count - 1
        while left <= right {
            let mid = left + (right - left) / 2
            if arr[mid] == val {
                arr.remove(at: mid)
                return
            } else if arr[mid] < val {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
    }
}
