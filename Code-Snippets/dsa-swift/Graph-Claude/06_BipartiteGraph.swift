import Collections

// MARK: - Bipartite Graph Check
//
// ============================================================================
// INTUITION:
// A bipartite graph can be colored using exactly 2 colors such that NO two
// adjacent nodes share the same color. Think of it as dividing vertices into
// two groups where all edges go BETWEEN groups, never within a group.
//
// Key insight: A graph is bipartite if and only if it contains NO ODD-LENGTH CYCLE.
// - Any tree (no cycles) → always bipartite
// - Even-length cycle → bipartite
// - Odd-length cycle → NOT bipartite
//
// Algorithm: Try to 2-color the graph using BFS or DFS.
// Assign color 0 to start, alternate colors for neighbors.
// If a neighbor already has the SAME color as current node → not bipartite.
//
// USE CASES:
// 1. Matching problems (bipartite matching, stable marriage)
// 2. Checking if a graph can be 2-colored (scheduling conflicts)
// 3. Dividing items into two compatible groups
// 4. Detecting odd cycles
//
// USAGE PATTERNS:
// - BFS: Level-by-level coloring — even levels get color 0, odd levels get color 1
// - DFS: Assign opposite color to each neighbor recursively
// - Must handle disconnected graphs (check each component independently)
//
// TIME COMPLEXITY: O(V + E)
//   - Standard BFS/DFS traversal — each vertex and edge visited once
//   - O(V + 2E) for undirected graphs (each edge from both endpoints)
//
// SPACE COMPLEXITY: O(V)
//   - Color array: O(V)
//   - Queue (BFS) or recursion stack (DFS): O(V)
// ============================================================================

// MARK: - Using BFS

/// Checks if an undirected graph is bipartite using BFS 2-coloring.
/// - Returns: true if the graph is bipartite (2-colorable)
func isBipartiteBFS(graph: [[Int]], vertexCount: Int) -> Bool {
    // -1 means uncolored, 0 and 1 are the two colors
    var color = [Int](repeating: -1, count: vertexCount)

    // Must check every component (disconnected graph)
    for startNode in 0..<vertexCount {
        if color[startNode] != -1 { continue }   // Already colored

        var queue = Deque<Int>()
        color[startNode] = 0     // Assign first color to starting node
        queue.append(startNode)

        while let current = queue.popFirst() {
            for neighbor in graph[current] {
                if color[neighbor] == -1 {
                    // Uncolored neighbor → assign opposite color
                    color[neighbor] = 1 - color[current]
                    queue.append(neighbor)
                } else if color[neighbor] == color[current] {
                    // Same color as current → odd cycle → NOT bipartite
                    return false
                }
                // Different color → consistent coloring, continue
            }
        }
    }

    return true
}

// MARK: - Using DFS

/// Checks if an undirected graph is bipartite using DFS 2-coloring.
/// - Returns: true if the graph is bipartite (2-colorable)
func isBipartiteDFS(graph: [[Int]], vertexCount: Int) -> Bool {
    var color = [Int](repeating: -1, count: vertexCount)

    /// DFS helper that tries to color the graph starting from `node` with `c`.
    /// Returns false if a conflict is found (adjacent nodes with same color).
    func dfs(_ node: Int, _ c: Int) -> Bool {
        color[node] = c

        for neighbor in graph[node] {
            if color[neighbor] == -1 {
                // Assign opposite color and recurse
                if !dfs(neighbor, 1 - c) {
                    return false
                }
            } else if color[neighbor] == c {
                // Adjacent node has same color → NOT bipartite
                return false
            }
        }

        return true
    }

    // Handle disconnected components
    for node in 0..<vertexCount {
        if color[node] == -1 {
            if !dfs(node, 0) {
                return false
            }
        }
    }

    return true
}

// MARK: - Example Usage

func bipartiteExample() {
    // Bipartite graph (even cycle):
    //   0 -- 1
    //   |    |
    //   3 -- 2
    // Groups: {0, 2} and {1, 3}
    let bipartiteEdges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    var bipartiteGraph = [[Int]](repeating: [], count: 4)
    for (u, v) in bipartiteEdges {
        bipartiteGraph[u].append(v)
        bipartiteGraph[v].append(u)
    }

    print("BFS - Is bipartite:", isBipartiteBFS(graph: bipartiteGraph, vertexCount: 4))  // true
    print("DFS - Is bipartite:", isBipartiteDFS(graph: bipartiteGraph, vertexCount: 4))  // true

    // Non-bipartite graph (odd cycle / triangle):
    //   0 -- 1
    //    \  /
    //     2
    let nonBipartiteEdges = [(0, 1), (1, 2), (2, 0)]
    var nonBipartiteGraph = [[Int]](repeating: [], count: 3)
    for (u, v) in nonBipartiteEdges {
        nonBipartiteGraph[u].append(v)
        nonBipartiteGraph[v].append(u)
    }

    print("BFS - Is bipartite:", isBipartiteBFS(graph: nonBipartiteGraph, vertexCount: 3))  // false
    print("DFS - Is bipartite:", isBipartiteDFS(graph: nonBipartiteGraph, vertexCount: 3))  // false
}
