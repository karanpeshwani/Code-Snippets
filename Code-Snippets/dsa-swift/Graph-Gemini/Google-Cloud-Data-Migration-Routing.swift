import Collections

/* ==========================================
 Google Cloud Data Migration Routing
 ==========================================
 
 Question:
 Our global network is represented as an undirected graph where nodes are data centers 
 and edges are fiber optic links. Each link has two properties: bandwidth (in Gbps) and latency (in ms).
 Because this is a live database migration, the connection will drop if the total latency 
 of the path exceeds a given `maxLatency`.
 To complete the transfer as quickly as possible, we want to maximize the bottleneck bandwidth 
 of the chosen path. The bottleneck bandwidth is defined as the minimum bandwidth among all 
 individual links that make up the path.
  
 Task: Write a function that takes this network graph, a start node, an end node, and a maxLatency, 
 and returns the maximum possible bottleneck bandwidth of a valid path. If no path can satisfy 
 the latency constraint, return -1.
 
 Intuition/Explanation:
 We need to maximize the bottleneck bandwidth while ensuring the path latency <= maxLatency.
 This is a multi-objective optimization problem. We can solve it efficiently by combining Binary Search 
 with Dijkstra's shortest path algorithm.
 We can binary search the answer for the bottleneck bandwidth. For a given target bandwidth `B`, 
 we only consider edges in the graph that have a bandwidth >= `B`. We then run Dijkstra's algorithm 
 to find the path with the minimum total latency from `start` to `end` using only these valid edges.
 If the resulting minimum latency is <= maxLatency, then a bottleneck bandwidth of `B` is achievable, 
 and we can try a larger bandwidth. Otherwise, we must try a smaller bandwidth.
 
 Time Complexity: O(E log V * log(MaxBandwidth)), where E is the number of edges and V is the number of nodes.
 Space Complexity: O(V + E) for Dijkstra's distance array, priority queue, and adjacency list processing.
*/

struct Link {
    let destination: Int
    let bandwidth: Int
    let latency: Int
}

struct LatencyState: Comparable {
    let latency: Int
    let node: Int
    
    static func < (lhs: LatencyState, rhs: LatencyState) -> Bool {
        return lhs.latency < rhs.latency // Minimize latency
    }
}

class SolutionDataMigration {
    func findMaxBottleneck(network: [[Link]], start: Int, end: Int, maxLatency: Int) -> Int {
        let n = network.count
        
        // Find the maximum possible bandwidth in the network to set the upper bound for binary search
        var maxB = 0
        for links in network {
            for link in links {
                maxB = max(maxB, link.bandwidth)
            }
        }
        
        var low = 0
        var high = maxB
        var bestBottleneck = -1
        
        // Helper function to check if there is a path with bottleneck >= minBandwidth and latency <= maxLatency
        func isValid(minBandwidth: Int) -> Bool {
            var minLatency = Array(repeating: Int.max, count: n)
            minLatency[start] = 0
            
            var pq = Heap<LatencyState>()
            pq.insert(LatencyState(latency: 0, node: start))
            
            while let current = pq.popMin() {
                let u = current.node
                let lat = current.latency
                
                if lat > minLatency[u] { continue }
                if u == end { return lat <= maxLatency }
                
                for link in network[u] {
                    // Only traverse links that meet the required bottleneck bandwidth
                    if link.bandwidth >= minBandwidth {
                        let nextLat = lat + link.latency
                        if nextLat < minLatency[link.destination] {
                            minLatency[link.destination] = nextLat
                            pq.insert(LatencyState(latency: nextLat, node: link.destination))
                        }
                    }
                }
            }
            
            return minLatency[end] <= maxLatency
        }
        
        // Binary search for the maximum bottleneck bandwidth
        while low <= high {
            let mid = low + (high - low) / 2
            if isValid(minBandwidth: mid) {
                bestBottleneck = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        return bestBottleneck
    }
}
