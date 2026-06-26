// 759. Employee Free Time
// Link: https://leetcode.com/problems/employee-free-time/
//
// Time Complexity: O(N log K), where N is the total number of intervals and K is the number of employees.
// Explanation: We use a Min-Heap of size K to merge the sorted schedules of all employees. Each insertion and extraction takes O(log K).
// Space Complexity: O(K)
// Explanation: The heap stores at most one interval from each of the K employees at any given time.

import Collections

// Definition for an Interval.
public class Interval {
    public var start: Int
    public var end: Int
    public init(_ start: Int, _ end: Int) {
        self.start = start
        self.end = end
    }
}

// Wrapper structure to store interval along with its employee and internal index
struct Element: Comparable {
    let start: Int
    let end: Int
    let employeeIdx: Int
    let intervalIdx: Int
    
    static func < (lhs: Element, rhs: Element) -> Bool {
        return lhs.start < rhs.start
    }
}

class Solution {
    func employeeFreeTime(_ schedule: [[Interval]]) -> [Interval] {
        var minHeap = Heap<Element>()
        
        // Insert the first interval of each employee into the heap
        for (i, employee) in schedule.enumerated() {
            if let first = employee.first {
                minHeap.insert(Element(start: first.start, end: first.end, employeeIdx: i, intervalIdx: 0))
            }
        }
        
        guard let firstElement = minHeap.min else { return [] }
        var currentEnd = firstElement.end
        var freeTime = [Interval]()
        
        // Process the intervals in chronological order
        while !minHeap.isEmpty {
            let element = minHeap.removeMin()
            
            if element.start > currentEnd {
                // Gap found, it's common free time
                freeTime.append(Interval(currentEnd, element.start))
                currentEnd = element.end
            } else {
                // Overlap, update max end time to extend the working period
                currentEnd = max(currentEnd, element.end)
            }
            
            // Advance to the next interval for the employee we just processed
            let nextIntervalIdx = element.intervalIdx + 1
            let employee = schedule[element.employeeIdx]
            
            if nextIntervalIdx < employee.count {
                let nextInterval = employee[nextIntervalIdx]
                minHeap.insert(Element(
                    start: nextInterval.start, 
                    end: nextInterval.end, 
                    employeeIdx: element.employeeIdx, 
                    intervalIdx: nextIntervalIdx
                ))
            }
        }
        
        return freeTime
    }
}
