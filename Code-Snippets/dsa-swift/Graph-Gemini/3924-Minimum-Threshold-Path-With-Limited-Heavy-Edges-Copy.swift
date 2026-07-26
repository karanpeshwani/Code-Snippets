import Collections

/* ==========================================
 3924. Minimum Threshold Path With Limited Heavy Edges
 ==========================================
 
 https://leetcode.com/problems/minimum-threshold-path-with-limited-heavy-edges/description/
 
 Question:
 You are given an undirected weighted graph with n nodes and a list of edges, each with a specific weight.
 You are also provided with a `source` node, a `target` node, and an integer `k`.
 
 A chosen threshold value categorizes edges into two types:
 - Light Edges: Weights <= threshold.
 - Heavy Edges: Weights > threshold.
 
 A path is considered valid if the number of heavy edges in that path is at most `k`.
 
 Goal: Find the minimum integer threshold such that there exists at least one valid path 
 from the source to the target. If no such path exists, return -1.
 
 Intuition/Explanation:
 The threshold property is monotonic: if a threshold `T` is valid (we can reach target with <= k heavy edges), 
 then any threshold `T' > T` is also valid because it only makes more edges "light".
 Thus, we can use Binary Search to find the minimum threshold.
 
 For a given threshold, we can determine if a valid path exists by using 0-1 BFS:
 - Treat all edges with weight <= threshold as having cost 0.
 - Treat all edges with weight > threshold as having cost 1.
 - Use a Deque to find the shortest path in terms of cost (number of heavy edges).
 - If the shortest path cost is <= k, then this threshold is valid.
 
 Time Complexity: O(E log W) where E is the number of edges and W is the max edge weight. 
 Binary search takes O(log W) iterations, and each 0-1 BFS takes O(V + E) time.
 Space Complexity: O(V + E) for the adjacency list and the Deque used in BFS.
*/

class Solution {
    func minimumThreshold(_ n: Int, _ edges: [[Int]], _ source: Int, _ target: Int, _ k: Int) -> Int {
        // Find max node to size adj appropriately (handles both 0-indexed and 1-indexed graphs)
        var maxNode = n
        var maxWeight = 0
        
        for edge in edges {
            maxNode = max(maxNode, max(edge[0], edge[1]))
            maxWeight = max(maxWeight, edge[2])
        }
        
        var adj = Array(repeating: [(v: Int, w: Int)](), count: maxNode + 1)
        
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let w = edge[2]
            adj[u].append((v, w))
            adj[v].append((u, w))
        }
        
        // Helper function for 0-1 BFS
        func isValidThreshold(_ threshold: Int) -> Bool {
            var deque = Deque<Int>()
            var dist = Array(repeating: Int.max, count: maxNode + 1)
            
            deque.append(source)
            dist[source] = 0
            
            while let u = deque.popFirst() {
                // If we popped target, we know we found the minimum cost to reach it
                if u == target { break }
                
                for neighbor in adj[u] {
                    let v = neighbor.v
                    let w = neighbor.w
                    let cost = (w > threshold) ? 1 : 0
                    
                    if dist[u] + cost < dist[v] {
                        dist[v] = dist[u] + cost
                        // Cost 0 goes to front, cost 1 goes to back (0-1 BFS property)
                        if cost == 0 {
                            deque.prepend(v)
                        } else {
                            deque.append(v)
                        }
                    }
                }
            }
            
            return dist[target] <= k
        }
        
        var low = 0
        var high = maxWeight
        var ans = -1
        
        // Binary search the threshold
        while low <= high {
            let mid = low + (high - low) / 2
            
            if isValidThreshold(mid) {
                ans = mid
                high = mid - 1 // Try to find a smaller valid threshold
            } else {
                low = mid + 1  // Threshold is too small, need more light edges
            }
        }
        
        return ans
    }
}



//Approach 2:
// Define a state to store in our Min-Heap, conforming to Comparable
struct State: Comparable {
    let node: Int
    let cost: Int
    
    // We want a Min-Heap based on cost
    static func < (lhs: State, rhs: State) -> Bool {
        return lhs.cost < rhs.cost
    }
}

class Solution {
    func minimumThreshold(_ n: Int, _ edges: [[Int]], _ source: Int, _ target: Int, _ k: Int) -> Int {
        // 1. Build the adjacency list and find the max weight
        var adj = [[(node: Int, weight: Int)]](repeating: [], count: n)
        var maxWeight = 0
        
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let w = edge[2]
            
            adj[u].append((node: v, weight: w))
            adj[v].append((node: u, weight: w))
            maxWeight = max(maxWeight, w)
        }
        
        // 2. Dijkstra's Algorithm to validate a threshold
        func isValid(_ threshold: Int) -> Bool {
            var dist = [Int](repeating: Int.max, count: n)
            dist[source] = 0
            
            var heap = Heap<State>()
            heap.insert(State(node: source, cost: 0))
            
            while let curr = heap.popMin() {
                let u = curr.node
                let currentCost = curr.cost
                
                // If we found a strictly better path earlier, skip processing
                if currentCost > dist[u] { continue }
                
                // Early exit if we reached the target within our budget
                if u == target && currentCost <= k { return true }
                
                for neighbor in adj[u] {
                    let v = neighbor.node
                    let weight = neighbor.weight
                    
                    // Edges <= threshold cost 0, edges > threshold cost 1
                    let edgeCost = weight > threshold ? 1 : 0
                    let newCost = currentCost + edgeCost
                    
                    if newCost < dist[v] {
                        dist[v] = newCost
                        heap.insert(State(node: v, cost: newCost))
                    }
                }
            }
            
            return dist[target] <= k
        }
        
        // Base check: is the target reachable even if we consider ALL edges as light?
        if !isValid(maxWeight) { return -1 }
        
        // 3. Binary Search for the answer
        var left = 0
        var right = maxWeight
        var ans = -1
        
        while left <= right {
            let mid = left + (right - left) / 2
            
            if isValid(mid) {
                ans = mid        // mid works, see if we can find a strictly smaller threshold
                right = mid - 1
            } else {
                left = mid + 1   // mid failed, we need to allow larger edges
            }
        }
        
        return ans
    }
}



//Approach 3:
struct State: Comparable {
    let threshold: Int
    let heavyUsed: Int
    let node: Int
    
    // Sort primarily by lowest threshold (ascending)
    // Tie-breaker: fewest heavy edges used (ascending)
    static func < (lhs: State, rhs: State) -> Bool {
        if lhs.threshold != rhs.threshold {
            return lhs.threshold < rhs.threshold
        }
        return lhs.heavyUsed < rhs.heavyUsed
    }
}

class Solution {
    func minimumThreshold(_ n: Int, _ edges: [[Int]], _ source: Int, _ target: Int, _ k: Int) -> Int {
        // 1. Build adjacency list
        var adj = [[(v: Int, w: Int)]](repeating: [], count: n)
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            let w = edge[2]
            adj[u].append((v: v, w: w))
            adj[v].append((v: u, w: w))
        }
        
        var pq = Heap<State>()
        pq.insert(State(threshold: 0, heavyUsed: 0, node: source))
        
        // minHeavy[node] tracks the fewest heavy edges used to reach `node` so far.
        // Because PQ pops in increasing order of threshold, a later state is only
        // useful if it uses STRICTLY FEWER heavy edges.
        var minHeavy = [Int](repeating: Int.max, count: n)
        
        while let curr = pq.popMin() {
            let u = curr.node
            let t = curr.threshold
            let h = curr.heavyUsed
            
            // First time we hit the target, it's guaranteed to be the minimum threshold
            if u == target {
                return t
            }
            
            // Prune strictly worse states
            if h >= minHeavy[u] {
                continue
            }
            minHeavy[u] = h
            
            for neighbor in adj[u] {
                let v = neighbor.v
                let w = neighbor.w
                
                // Option 1: Treat as a Light Edge
                // Threshold becomes the max of the current path threshold and this edge
                pq.insert(State(threshold: max(t, w), heavyUsed: h, node: v))
                
                // Option 2: Treat as a Heavy Edge
                // Threshold stays the same, but we consume 1 allowance
                if h < k {
                    pq.insert(State(threshold: t, heavyUsed: h + 1, node: v))
                }
            }
        }
        
        return -1
    }
}
