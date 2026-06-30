//Again
// 502-IPO.swift
// 502. IPO
// https://leetcode.com/problems/ipo/
//
// Time Complexity: O(N log N) to sort projects by capital and O(K log N) to extract max from the priority queue. Total O((N + K) log N).
// Space Complexity: O(N) for storing the projects and the priority queue.

import Collections

class Solution {
    func findMaximizedCapital(_ k: Int, _ w: Int, _ profits: [Int], _ capital: [Int]) -> Int {
        let n = profits.count
        var projects = [(capital: Int, profit: Int)]()
        for i in 0..<n {
            projects.append((capital[i], profits[i]))
        }
        
        // Sort projects by required capital
        projects.sort { $0.capital < $1.capital }
        
        var maxHeap = Heap<Int>()
        var currentCapital = w
        var projectIndex = 0
        
        for _ in 0..<k {
            // Add all projects we can afford to the max heap
            while projectIndex < n && projects[projectIndex].capital <= currentCapital {
                maxHeap.insert(projects[projectIndex].profit)
                projectIndex += 1
            }
            
            // If we can't afford any more projects and heap is empty, we are done
            if maxHeap.isEmpty {
                break
            }
            
            // Do the project that yields the maximum profit
            currentCapital += maxHeap.removeMax()
        }
        
        return currentCapital
    }
}
