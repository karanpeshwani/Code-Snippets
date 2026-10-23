//Again
// 815-Bus-Routes.swift
// 815. Bus Routes
// https://leetcode.com/problems/bus-routes/

/*
 Intution: BFS from the startNode till we reach the target node.
 Time Complexity: O(N * M), where N is the number of bus routes and M is the maximum number of stops in a single route.
 Generating the stop to buses map takes O(N * M). The BFS visits each bus at most once and processes all its stops, taking O(N * M) overall.
 Space Complexity: O(N * M) to store the mapping from stops to buses, and for the queue and visited sets.
*/

class Solution {
    func numBusesToDestination(_ routes: [[Int]], _ source: Int, _ target: Int) -> Int {
        if source == target { return 0 }

        let n: Int = routes.count
        // 1. Replaced the fixed array with a Dictionary
        var nodeBusses: [Int: [Int]] = [:]

        for i in 0..<n {
            for node in routes[i] {
                // Safely initialize an empty array if the key doesn't exist yet
                nodeBusses[node, default: []].append(i)
            }
        }

        var queue: Deque<Int> = Deque()
        // 2. Replaced the fixed boolean array with a Set
        var visitedNodes: Set<Int> = []
        var visitedBusses: [Bool] = Array(repeating: false, count: n)

        queue.append(source)
        visitedNodes.insert(source)
        var level = 0

        while !queue.isEmpty {
            let size = queue.count
            var nextQueue: Deque<Int> = Deque()

            for _ in 0..<size {
                let topNode = queue.removeFirst()

                // Use ?? [] to handle cases where a node might not have any buses
                // (though logically impossible here based on how we built it, Swift requires it)
                for bus in nodeBusses[topNode] ?? [] {
                    guard !visitedBusses[bus] else { continue }
                    visitedBusses[bus] = true

                    for busNode in routes[bus] {
                        if busNode == target { return level + 1 }
                        
                        // 3. Check for inclusion in the Set rather than indexing an array
                        guard !visitedNodes.contains(busNode) else { continue }
                        visitedNodes.insert(busNode)
                        nextQueue.append(busNode)
                    }
                }
            }

            level += 1
            queue = nextQueue
        }

        return -1
    }
}
