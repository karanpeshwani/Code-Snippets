// 834. Sum of Distances in Tree
// https://leetcode.com/problems/sum-of-distances-in-tree

/*
 Intuition:
 A naive approach is to do a BFS/DFS from every node, taking O(N^2) time. We need O(N).
 We can use Tree DP.
 Let `count[i]` be the number of nodes in the subtree rooted at `i`.
 Let `ans[i]` be the sum of distances from node `i` to all other nodes.
 
 1. Post-order DFS: Compute `count` and the sum of distances from the root to all nodes in its subtree.
    For a node `u` and its child `v`: `count[u] += count[v]` and `ans[u] += ans[v] + count[v]`.
 2. Pre-order DFS: Calculate the answer for all nodes using the parent's answer.
    When moving from parent `u` to child `v`, the distance to nodes in `v`'s subtree decreases by 1
    (so we subtract `count[v]`), and the distance to the rest of the nodes increases by 1
    (so we add `N - count[v]`).
    Thus, `ans[v] = ans[u] - count[v] + N - count[v]`.

 Time Complexity: O(N)
 - Building the graph takes O(N).
 - The post-order DFS processes each edge twice, taking O(N).
 - The pre-order DFS also takes O(N).
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - The adjacency list for the graph takes O(N) space.
 - The `count` and `ans` arrays take O(N) space.
 - The recursion stack depth can be O(N) in the worst case (skewed tree).
 - Overall space complexity is O(N).
 */

class Solution {
    func sumOfDistancesInTree(_ n: Int, _ edges: [[Int]]) -> [Int] {
        var graph = Array(repeating: [Int](), count: n)
        for edge in edges {
            graph[edge[0]].append(edge[1])
            graph[edge[1]].append(edge[0])
        }
        
        var count = Array(repeating: 1, count: n)
        var ans = Array(repeating: 0, count: n)
        
        // First pass: compute count and initial ans for subtree
        func postOrder(_ node: Int, _ parent: Int) {
            for child in graph[node] {
                if child != parent {
                    postOrder(child, node)
                    count[node] += count[child]
                    ans[node] += ans[child] + count[child]
                }
            }
        }
        
        // Second pass: compute final ans based on parent
        func preOrder(_ node: Int, _ parent: Int) {
            for child in graph[node] {
                if child != parent {
                    ans[child] = ans[node] - count[child] + (n - count[child])
                    preOrder(child, node)
                }
            }
        }
        
        postOrder(0, -1)
        preOrder(0, -1)
        
        return ans
    }
}
