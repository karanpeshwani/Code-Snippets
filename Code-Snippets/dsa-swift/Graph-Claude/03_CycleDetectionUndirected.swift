import Collections

// MARK: - Cycle Detection in Undirected Graph
//
// ============================================================================
// INTUITION:
// In an undirected graph, a cycle exists if during traversal we encounter a
// node that has ALREADY been visited AND is NOT the parent of the current node.
// The parent check is crucial — in undirected graphs, edge (u,v) means both
// u→v and v→u exist, so going back to parent doesn't count as a cycle.
//
// USE CASES:
// 1. Detecting circular dependencies
// 2. Validating tree structure (a tree is an acyclic connected graph)
// 3. Network redundancy detection
// 4. Checking if adding an edge creates a cycle (Union-Find is better for this)
//
// USAGE PATTERNS:
// - BFS approach: Track parent of each node; if a neighbor is visited and not parent → cycle
// - DFS approach: Same logic but using recursion; pass parent as parameter
// - For undirected graphs: MUST track parent to avoid false positives
//
// TIME COMPLEXITY: O(V + E)
//   - Each vertex and edge visited at most once
//   - Same as standard BFS/DFS traversal
//
// SPACE COMPLEXITY: O(V)
//   - Visited array: O(V)
//   - Queue (BFS) or recursion stack (DFS): O(V) worst case
// ============================================================================

// MARK: - Using BFS

/// Detects cycle in an undirected graph using BFS.
/// Tracks parent of each node — if we find a visited neighbor that isn't our parent, cycle exists.
func hasCycleBFS(graph: [[Int]], vertexCount: Int) -> Bool {
    var visited = [Bool](repeating: false, count: vertexCount)

    // Check each component (graph may be disconnected)
    for startNode in 0..<vertexCount {
        if visited[startNode] { continue }

        // BFS with (node, parent) pairs
        var queue = Deque<(node: Int, parent: Int)>()
        visited[startNode] = true
        queue.append((startNode, -1))   // Source has no parent → -1

        while let (current, parent) = queue.popFirst() {
            for neighbor in graph[current] {
                if !visited[neighbor] {
                    visited[neighbor] = true
                    queue.append((neighbor, current))
                } else if neighbor != parent {
                    // Visited neighbor that is NOT our parent → CYCLE FOUND
                    // This means there's another path to reach this neighbor
                    return true
                }
            }
        }
    }

    return false
}

// MARK: - Using DFS

/// Detects cycle in an undirected graph using DFS.
/// Passes parent to each recursive call to distinguish back-edges from parent-edges.
func hasCycleDFS(graph: [[Int]], vertexCount: Int) -> Bool {
    var visited = [Bool](repeating: false, count: vertexCount)

    /// DFS helper that returns true if a cycle is found.
    /// - Parameters:
    ///   - node: Current node being explored
    ///   - parent: The node from which we arrived at current node
    func dfs(_ node: Int, parent: Int) -> Bool {
        visited[node] = true

        for neighbor in graph[node] {
            if !visited[neighbor] {
                // Explore unvisited neighbor — current node becomes its parent
                if dfs(neighbor, parent: node) {
                    return true
                }
            } else if neighbor != parent {
                // Neighbor is visited AND is not our parent → back edge → CYCLE
                return true
            }
        }

        return false
    }

    // Handle disconnected components
    for node in 0..<vertexCount {
        if !visited[node] {
            if dfs(node, parent: -1) {
                return true
            }
        }
    }

    return false
}

// MARK: - Example Usage

func cycleUndirectedExample() {
    // Graph WITH cycle:
    //   0 -- 1
    //   |    |
    //   2 -- 3
    let edgesWithCycle = [(0, 1), (1, 3), (3, 2), (2, 0)]
    var graphCycle = [[Int]](repeating: [], count: 4)
    for (u, v) in edgesWithCycle {
        graphCycle[u].append(v)
        graphCycle[v].append(u)
    }

    print("BFS - Has cycle:", hasCycleBFS(graph: graphCycle, vertexCount: 4))   // true
    print("DFS - Has cycle:", hasCycleDFS(graph: graphCycle, vertexCount: 4))   // true

    // Graph WITHOUT cycle (tree):
    //   0 -- 1 -- 2
    let edgesNoCycle = [(0, 1), (1, 2)]
    var graphTree = [[Int]](repeating: [], count: 3)
    for (u, v) in edgesNoCycle {
        graphTree[u].append(v)
        graphTree[v].append(u)
    }

    print("BFS - Has cycle:", hasCycleBFS(graph: graphTree, vertexCount: 3))   // false
    print("DFS - Has cycle:", hasCycleDFS(graph: graphTree, vertexCount: 3))   // false
}
