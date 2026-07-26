import Collections

/* ==========================================
 3924. Minimum Threshold Path With Limited Heavy Edges
 ==========================================
 
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
