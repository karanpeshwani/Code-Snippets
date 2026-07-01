//Again
// 815-Bus-Routes.swift
// 815. Bus Routes
// https://leetcode.com/problems/bus-routes/
//
// Time Complexity: O(N * M), where N is the number of bus routes and M is the maximum number of stops in a single route.
// Generating the stop to buses map takes O(N * M). The BFS visits each bus at most once and processes all its stops, taking O(N * M) overall.
// Space Complexity: O(N * M) to store the mapping from stops to buses, and for the queue and visited sets.

class Solution {
    func numBusesToDestination(_ routes: [[Int]], _ source: Int, _ target: Int) -> Int {
        // If we are already at the target, 0 buses are needed
        if source == target { return 0 }
        
        // Map each stop to the list of bus indices that pass through it
        var stopToBuses = [Int: [Int]]()
        for (i, route) in routes.enumerated() {
            for stop in route {
                stopToBuses[stop, default: []].append(i)
            }
        }
        
        // Queue for BFS, storing tuples of (busIndex, depth)
        var queue = [(Int, Int)]()
        var visitedBuses = Set<Int>()
        var visitedStops = Set<Int>()
        
        // Start from all buses passing through the source stop
        if let startingBuses = stopToBuses[source] {
            for bus in startingBuses {
                queue.append((bus, 1))
                visitedBuses.insert(bus)
            }
        }
        visitedStops.insert(source)
        
        var head = 0
        while head < queue.count {
            let (busIndex, depth) = queue[head]
            head += 1
            
            // Check all stops in the current bus's route
            for stop in routes[busIndex] {
                // If we reached the target stop, return the current depth
                if stop == target {
                    return depth
                }
                
                // If we haven't visited this stop yet, process it
                if !visitedStops.contains(stop) {
                    visitedStops.insert(stop)
                    
                    // Add all unvisited buses that pass through this stop to the queue
                    if let nextBuses = stopToBuses[stop] {
                        for nextBus in nextBuses {
                            if !visitedBuses.contains(nextBus) {
                                visitedBuses.insert(nextBus)
                                queue.append((nextBus, depth + 1))
                            }
                        }
                    }
                }
            }
        }
        
        // Target is unreachable
        return -1
    }
}
