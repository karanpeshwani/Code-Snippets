// 871. Minimum Number of Refueling Stops
// https://leetcode.com/problems/minimum-number-of-refueling-stops

/*
 Intuition:
 As we drive towards the target, we pass gas stations. Instead of deciding to stop at a station
 when we pass it, we can imagine that we "take the gas with us" in the trunk without stopping.
 Later, if we run out of gas, we can look into our trunk (the stations we passed) and use the
 gas from the station that provided the MOST gas. This guarantees we get the maximum reach with
 the minimum number of stops.
 We can use a Max-Heap to keep track of the gas capacities of the stations we've passed.
 Whenever our current gas is not enough to reach the next station (or the target), we pop the
 largest gas amount from the Max-Heap and increment our stop count, until we can reach the next point.

 Time Complexity: O(N log N)
 - We iterate over each of the N stations exactly once.
 - Pushing and popping from the Max-Heap takes O(log N) time.
 - In the worst case, we might push and pop N times, leading to O(N log N) time complexity.

 Space Complexity: O(N)
 - The Max-Heap can store up to N elements (if we pass all stations without stopping initially).
 - Overall space complexity is O(N).
 */

import Collections

class Solution {
    func minRefuelStops(_ target: Int, _ startFuel: Int, _ stations: [[Int]]) -> Int {
        var maxHeap = Heap<Int>(sort: >) // Max-Heap to store available fuel
        var currentFuel = startFuel
        var stops = 0
        var previousPosition = 0
        
        var stations = stations
        stations.append([target, 0]) // Add target as a dummy station
        
        for station in stations {
            let location = station[0]
            let capacity = station[1]
            
            // Fuel consumed to reach this station
            currentFuel -= (location - previousPosition)
            
            // If we ran out of fuel before reaching this station, use fuel from maxHeap
            while currentFuel < 0 && !maxHeap.isEmpty {
                currentFuel += maxHeap.popMax()!
                stops += 1
            }
            
            // If still out of fuel, it's impossible to reach
            if currentFuel < 0 {
                return -1
            }
            
            // Add current station's capacity to maxHeap (put in the trunk)
            maxHeap.insert(capacity)
            previousPosition = location
        }
        
        return stops
    }
}
