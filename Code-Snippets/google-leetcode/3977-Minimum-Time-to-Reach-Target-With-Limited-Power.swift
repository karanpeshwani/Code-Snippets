// 3977. Minimum Time to Reach Target With Limited Power
// https://leetcode.com/problems/minimum-time-to-reach-target-with-limited-power
//
// Intuition/Explanation:
// This is a shortest path problem with a state constraint (power). We need to find the minimum time 
// to reach the target, and in case of a tie, the path that maximizes the remaining power.
// We can use Dijkstra's Algorithm with a modified state: `(time, remaining_power, node)`.
// We use a Min-Heap to prioritize paths with the smallest time, and then the largest remaining power.
// A node `u` can transition to a neighbor `v` if the current `remaining_power >= cost[u]`.
// We also maintain a `bestPower` array to prune suboptimal states. `bestPower[u]` stores the maximum 
// power we had when reaching node `u` so far. Since Dijkstra processes states in increasing order of time, 
// if we reach node `u` again with less than or equal power, it's a strictly worse state and can be skipped.
//
// Time Complexity: O(E log (N * P)), where E is the number of edges, N is nodes, and P is the max power.
// Space Complexity: O(N * P) worst case for the Priority Queue, and O(N) for the best power map.

struct State: Comparable {
    let time: Int
    let remainingPower: Int
    let node: Int
    
    // Sort primarily by time (ascending), then by remaining power (descending)
    static func < (lhs: State, rhs: State) -> Bool {
        if lhs.time != rhs.time {
            return lhs.time < rhs.time
        }
        return lhs.remainingPower > rhs.remainingPower
    }
}


class Solution {
    func minimumTime(_ n: Int, _ edges: [[Int]], _ power: Int, _ cost: [Int], _ source: Int, _ target: Int) -> [Int] {
        // Build adjacency list
        var adj = Array(repeating: [(v: Int, t: Int)](), count: n)
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let t = edge[2]
            adj[u].append((v: v, t: t))
        }
        
        var pq = Heap<State>()
        pq.insert(State(time: 0, remainingPower: power, node: source))
        
        // bestPower[node] tracks the max power we had when arriving at `node`.
        // If we arrive at `node` with power <= bestPower[node], it's a suboptimal path.
        var bestPower = Array(repeating: -1, count: n)
        
        while let current = pq.popMin() {
            let u = current.node
            let p = current.remainingPower
            let t = current.time
            
            if u == target {
                return [t, p]
            }
            
            // Prune strictly worse states
            if p <= bestPower[u] {
                continue
            }
            bestPower[u] = p
            
            // Check if we have enough power to move from `u`
            if p >= cost[u] {
                let nextPower = p - cost[u]
                for neighbor in adj[u] {
                    pq.insert(State(time: t + neighbor.t, remainingPower: nextPower, node: neighbor.v))
                }
            }
        }
        
        return [-1, -1]
    }
}
