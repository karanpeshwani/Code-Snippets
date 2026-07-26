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

// ==========================================
// Approach 2: Max-Heap Dijkstra (Maximize Bottleneck, Prune by Latency)
// ==========================================
// Intuition:
// Instead of binary search, we can use a Priority Queue (Max-Heap) that always explores paths 
// with the largest bottleneck bandwidth first.
// The state is `(bottleneck, latency, node)`. We prioritize maximum bottleneck, and then minimum latency.
// For pruning, we maintain `minLatency[node]` which tracks the shortest latency used to reach `node`.
// Since we process in decreasing order of bottleneck, any later path to `node` is only useful 
// if it has a strictly smaller latency. Otherwise, it's a worse state (smaller bottleneck AND larger latency).
// The first time we reach the `end` node with `latency <= maxLatency`, we are guaranteed it's the maximum possible bottleneck.
//
// Time Complexity: O(E log (V * E)), as we might insert multiple states per node.
// Space Complexity: O(V * E) for the Priority Queue in the worst case, and O(V) for minLatency array.

struct MaxBottleneckState: Comparable {
    let bottleneck: Int
    let latency: Int
    let node: Int
    
    // Sort primarily by highest bottleneck (descending)
    // Tie-breaker: lowest latency (ascending)
    static func < (lhs: MaxBottleneckState, rhs: MaxBottleneckState) -> Bool {
        if lhs.bottleneck != rhs.bottleneck {
            return lhs.bottleneck > rhs.bottleneck // Maximize bottleneck
        }
        return lhs.latency < rhs.latency // Minimize latency
    }
}

class SolutionDataMigrationApproach2 {
    func findMaxBottleneck(network: [[Link]], start: Int, end: Int, maxLatency: Int) -> Int {
        let n = network.count
        var pq = Heap<MaxBottleneckState>()
        
        // Start with infinite bottleneck since start node doesn't constrain bandwidth
        pq.insert(MaxBottleneckState(bottleneck: Int.max, latency: 0, node: start))
        
        var minLatency = Array(repeating: Int.max, count: n)
        
        while let curr = pq.popMin() {
            let u = curr.node
            let b = curr.bottleneck
            let l = curr.latency
            
            // First time we reach the end node within maxLatency, it's the max bottleneck
            if u == end && l <= maxLatency {
                return b == Int.max ? -1 : b
            }
            
            // Prune strictly worse states
            if l >= minLatency[u] {
                continue
            }
            minLatency[u] = l
            
            for link in network[u] {
                let nextB = min(b, link.bandwidth)
                let nextL = l + link.latency
                
                // Only enqueue if it doesn't exceed our maxLatency bound globally
                if nextL <= maxLatency {
                    pq.insert(MaxBottleneckState(bottleneck: nextB, latency: nextL, node: link.destination))
                }
            }
        }
        
        return -1
    }
}

/*
 Can an approach similar to binary search + minimum latency BFS be applied?

 The short answer is no, standard BFS cannot be used here (unless a very specific, rare condition is met).

 Here is why:

 Why 0-1 BFS worked for Problem 3924
 In problem 3924 (Minimum Threshold Path), we were able to use Binary Search + 0-1 BFS because the "cost" of taking an edge was strictly simplified to either 0 (light edge) or 1 (heavy edge). Because the edge weights are constrained to just 0 and 1, a Deque (0-1 BFS) can perfectly guarantee the shortest path in $O(V+E)$ time.

 Why BFS fails for Google Cloud Data Migration
 In the Data Migration problem, the "cost" of taking an edge is its latency. Latencies are arbitrary, variable integers (e.g., 5ms, 12ms, 50ms).

 Standard BFS only finds the shortest path in terms of the number of edges. It assumes every edge has an identical weight of 1. If you have one path with 2 edges that takes 100ms total, and another path with 4 edges that takes 10ms total, a standard BFS would incorrectly assume the 2-edge path is "shorter".

 To find the minimum latency path in a graph where edge weights (latencies) vary, you mathematically must use a weighted shortest-path algorithm. Dijkstra's Algorithm (which is essentially a BFS backed by a Priority Queue instead of a standard Queue) is the most efficient choice for this.

 (Note: The only exception where standard BFS would work for the Data Migration problem is if you were guaranteed that every single fiber optic link in the entire graph had the exact same latency, e.g., 1ms).
 */
