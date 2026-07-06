// 850. Rectangle Area II
// https://leetcode.com/problems/rectangle-area-ii

/*
 Intuition:
 To find the total area of overlapping rectangles, we can use a Line Sweep algorithm.
 We can imagine a vertical line sweeping from left to right across the x-axis.
 1. Extract all vertical edges (x-coordinate). A left edge adds a y-interval, a right edge removes a y-interval.
 2. Sort these edges by their x-coordinates.
 3. As we sweep from left to right, the active y-intervals change. The area added between two consecutive
    x-coordinates is the distance between them multiplied by the length of the union of active y-intervals.
 Because the number of rectangles is small (<= 200), we can just maintain a list of active y-intervals
 and compute their union length in O(N log N) time for each unique x.

 Time Complexity: O(N^2 log N)
 - There are 2N vertical edges. Sorting them takes O(N log N).
 - We process each edge, maintaining an active list of y-intervals (up to N intervals).
 - For each unique x, we sort the active y-intervals (O(N log N)) and compute the coverage (O(N)).
 - Overall time complexity is O(N^2 log N).

 Space Complexity: O(N)
 - The events array stores 2N edges, taking O(N) space.
 - The active list of y-intervals takes up to O(N) space.
 - Overall space complexity is O(N).
 */

class Solution {
    func rectangleArea(_ rectangles: [[Int]]) -> Int {
        let mod = 1_000_000_007
        
        // (x, y1, y2, type) where type is 1 for left edge, -1 for right edge
        var events = [(x: Int, y1: Int, y2: Int, type: Int)]()
        
        for rect in rectangles {
            events.append((x: rect[0], y1: rect[1], y2: rect[3], type: 1))
            events.append((x: rect[2], y1: rect[1], y2: rect[3], type: -1))
        }
        
        // Sort events primarily by x, then by type
        events.sort {
            if $0.x == $1.x {
                return $0.type > $1.type
            }
            return $0.x < $1.x
        }
        
        var activeIntervals = [(y1: Int, y2: Int)]()
        var totalArea = 0
        var prevX = events[0].x
        
        for event in events {
            // Calculate area added from prevX to current event's x
            let currentX = event.x
            if currentX > prevX {
                let width = currentX - prevX
                let height = calculateCoverage(activeIntervals)
                totalArea = (totalArea + width * height) % mod
            }
            
            // Update active intervals
            if event.type == 1 {
                activeIntervals.append((y1: event.y1, y2: event.y2))
            } else {
                if let index = activeIntervals.firstIndex(where: { $0.y1 == event.y1 && $0.y2 == event.y2 }) {
                    activeIntervals.remove(at: index)
                }
            }
            
            prevX = currentX
        }
        
        return totalArea
    }
    
    // Calculates the length of the union of the given intervals
    private func calculateCoverage(_ intervals: [(y1: Int, y2: Int)]) -> Int {
        if intervals.isEmpty { return 0 }
        
        let sortedIntervals = intervals.sorted { $0.y1 < $1.y1 }
        
        var coverage = 0
        var currentStart = sortedIntervals[0].y1
        var currentEnd = sortedIntervals[0].y2
        
        for i in 1..<sortedIntervals.count {
            let interval = sortedIntervals[i]
            if interval.y1 <= currentEnd {
                currentEnd = max(currentEnd, interval.y2)
            } else {
                coverage += currentEnd - currentStart
                currentStart = interval.y1
                currentEnd = interval.y2
            }
        }
        
        coverage += currentEnd - currentStart
        return coverage
    }
}
