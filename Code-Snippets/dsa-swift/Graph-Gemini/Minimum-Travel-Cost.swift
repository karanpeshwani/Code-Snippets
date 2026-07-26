import Collections

/* ==========================================
 Minimum Travel Cost
 ==========================================
 
 Question:
 There is a network of n cities numbered 0 to n - 1, connected by bidirectional roads.
 Roads are given as edges: [[Int]] where edges[i] = [u, v, time] means there's a road between 
 city u and city v taking time minutes to traverse. Multiple roads can connect the same two cities.
 Each city has a toll fee: passingFees[j] is the cost to enter city j. You pay the toll every 
 time you pass through a city — including city 0 (start) and city n-1 (destination).
 Goal: Starting at city 0, reach city n - 1 in at most maxTime minutes.
 Return the minimum total toll cost. If no valid path exists, return -1.
 
 Intuition/Explanation:
 We need to minimize the cost, subject to a maximum time constraint.
 We can use Dijkstra's algorithm, prioritizing paths by the minimum cost accumulated so far.
 The state in our priority queue will be `(cost, time, node)`.
 Since we pop states in increasing order of cost, the first time we pop the destination node 
 (and its time is <= maxTime), we have found the minimum cost path.
 To avoid infinite loops and prune redundant paths, we maintain an array `minTimeAtNode` 
 which stores the minimum time it took to reach a node. Since we are processing in increasing 
 order of cost, if we reach a node with a time that is >= a previously recorded time for that 
 node, we can discard this state because it costs more (or same) and takes more (or same) time.
 
 Time Complexity: O(E log (V * maxTime)) where E is edges, V is vertices.
 Space Complexity: O(V * maxTime) for the queue in the worst case, and O(V) for minTimeAtNode.
*/

struct CostState: Comparable {
    let cost: Int
    let time: Int
    let node: Int
    
    static func < (lhs: CostState, rhs: CostState) -> Bool {
        if lhs.cost != rhs.cost {
            return lhs.cost < rhs.cost // Minimize cost
        }
        return lhs.time < rhs.time // Then minimize time
    }
}

class SolutionMinimumTravelCost {
    func minCost(_ maxTime: Int, _ edges: [[Int]], _ passingFees: [Int]) -> Int {
        let n = passingFees.count
        var adj = Array(repeating: [(v: Int, time: Int)](), count: n)
        
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let time = edge[2]
            adj[u].append((v, time))
            adj[v].append((u, time))
        }
        
        var pq = Heap<CostState>()
        // Start at city 0, cost is passingFees[0], time is 0
        pq.insert(CostState(cost: passingFees[0], time: 0, node: 0))
        
        var minTimeAtNode = Array(repeating: Int.max, count: n)
        
        while let current = pq.popMin() {
            let u = current.node
            let t = current.time
            let c = current.cost
            
            // If we've reached here previously with a strictly shorter or equal time, this path is worse.
            if t >= minTimeAtNode[u] { continue }
            minTimeAtNode[u] = t
            
            if u == n - 1 {
                return c
            }
            
            for neighbor in adj[u] {
                let nextTime = t + neighbor.time
                if nextTime <= maxTime {
                    let nextCost = c + passingFees[neighbor.v]
                    pq.insert(CostState(cost: nextCost, time: nextTime, node: neighbor.v))
                }
            }
        }
        
        return -1
    }
}
