import Foundation

/*
 DFS (Depth-First Search)

 Intuition:
 DFS explores as deep as possible along each branch before backtracking.
 It goes down a path until it hits a dead end (a node with no unvisited neighbors),
 then it steps back and tries the next available path.
 It naturally uses the Call Stack (Recursion) or an explicit Stack (LIFO - Last In First Out).

 Usecases & Usage Patterns:
 - Topological Sorting (using finishing times).
 - Cycle detection in both directed and undirected graphs.
 - Finding Strongly Connected Components (Kosaraju's or Tarjan's algorithms).
 - Solving mazes or puzzles where we need to find "a" path to the goal.
 - Pattern: Keep a `visited` array. Mark node visited as soon as you enter the recursive call.

 Time Complexity: O(V + E)
 - V is the number of vertices, E is the number of edges.
 - Every vertex is visited exactly once O(V), and every edge is examined exactly once (or twice in undirected graphs) O(E).

 Space Complexity: O(V)
 - O(V) for the `visited` array.
 - O(V) for the recursion call stack in the worst-case scenario (a skewed graph / linear chain of nodes).
*/

func dfsTraversal(V: Int, adj: [[Int]], start: Int) -> [Int] {
    var visited = Array(repeating: false, count: V)
    var result: [Int] = []
    
    func dfs(node: Int) {
        // Mark current node as visited and process it
        visited[node] = true
        result.append(node)
        
        // Traverse all adjacent nodes
        for neighbor in adj[node] {
            if !visited[neighbor] {
                dfs(node: neighbor)
            }
        }
    }
    
    dfs(node: start)
    return result
}
