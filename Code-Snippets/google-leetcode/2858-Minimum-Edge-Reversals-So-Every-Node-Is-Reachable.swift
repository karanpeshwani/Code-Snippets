// 2858-Minimum-Edge-Reversals-So-Every-Node-Is-Reachable.swift
// 2858. Minimum Edge Reversals So Every Node Is Reachable
// https://leetcode.com/problems/minimum-edge-reversals-so-every-node-is-reachable/
//
// Time Complexity: O(N) where N is the number of nodes. We perform two passes of DFS, processing each edge a constant number of times.
// Space Complexity: O(N) for adjacency lists and recursion stack.

class Solution {
    func minEdgeReversals(_ n: Int, _ edges: [[Int]]) -> [Int] {
        // graph stores pairs of (neighbor, isReversed)
        var graph = [Int: [(Int, Int)]]()
        for edge in edges {
            let u = edge[0]
            let v = edge[1]
            graph[u, default: []].append((v, 0)) // 0 means original direction
            graph[v, default: []].append((u, 1)) // 1 means reversed direction
        }
        
        var dp = Array(repeating: 0, count: n)
        
        // First DFS to calculate the cost to reach all nodes from root 0
        func dfs1(_ node: Int, _ parent: Int) {
            for (neighbor, cost) in graph[node, default: []] {
                if neighbor != parent {
                    dp[0] += cost
                    dfs1(neighbor, node)
                }
            }
        }
        
        dfs1(0, -1)
        
        // Second DFS to propagate the costs to other nodes
        func dfs2(_ node: Int, _ parent: Int) {
            for (neighbor, cost) in graph[node, default: []] {
                if neighbor != parent {
                    // Adjust cost based on edge direction
                    dp[neighbor] = dp[node] + (cost == 1 ? -1 : 1)
                    dfs2(neighbor, node)
                }
            }
        }
        
        dfs2(0, -1)
        return dp
    }
}
