import Collections

// MARK: - Cycle Detection in Directed Graph
//
// ============================================================================
// INTUITION:
// In a directed graph, cycle detection is different from undirected because
// parent tracking alone won't work. We need to detect BACK EDGES — edges
// that point to an ancestor in the current DFS path.
//
// Two approaches:
// 1. DFS with path-visited array: Maintain a "currently on DFS path" array.
//    If we encounter a node that is on the current DFS path → cycle.
//    The key insight: a visited node is NOT necessarily a cycle — it could
//    be visited from a different path. Only if it's on the CURRENT path.
//
// 2. BFS (Kahn's Algorithm / Topological Sort): If we can't produce a
//    topological ordering of ALL nodes, a cycle exists.
//    After processing, if some nodes have indegree > 0, they're in a cycle.
//
// USE CASES:
// 1. Deadlock detection in operating systems
// 2. Dependency resolution (can we build all packages?)
// 3. Course prerequisite validation
// 4. Detecting circular imports/references
//
// USAGE PATTERNS:
// - DFS approach: Use two arrays — visited[] and pathVisited[] (or recStack[])
// - BFS/Kahn's approach: If toposort doesn't include all nodes → cycle exists
//
// TIME COMPLEXITY: O(V + E)
//   - Both BFS and DFS visit each vertex and edge once
//
// SPACE COMPLEXITY: O(V)
//   - DFS: visited[] + pathVisited[] + recursion stack → O(V)
//   - BFS: indegree[] + queue → O(V)
// ============================================================================

// MARK: - Using DFS (Path-Visited Array)

/// Detects cycle in a directed graph using DFS with path tracking.
///
/// We maintain two boolean arrays:
/// - `visited[]`: Has this node been visited in ANY DFS call?
/// - `pathVisited[]`: Is this node on the CURRENT DFS recursion path?
///
/// A cycle exists when we encounter a node that is `pathVisited` — meaning
/// we've found a back edge to an ancestor in the current DFS tree.
func hasCycleDirectedDFS(graph: [[Int]], vertexCount: Int) -> Bool {
    var visited = [Bool](repeating: false, count: vertexCount)
    var pathVisited = [Bool](repeating: false, count: vertexCount)

    func dfs(_ node: Int) -> Bool {
        visited[node] = true
        pathVisited[node] = true     // Mark: this node is on current DFS path

        for neighbor in graph[node] {
            if !visited[neighbor] {
                if dfs(neighbor) { return true }
            } else if pathVisited[neighbor] {
                // Neighbor is visited AND on current path → BACK EDGE → CYCLE
                // This is the critical distinction from undirected cycle detection
                return true
            }
            // If visited but NOT on current path: it was fully explored from
            // another branch — no cycle through this edge (cross edge)
        }

        pathVisited[node] = false    // Backtrack: remove from current path
        return false
    }

    for node in 0..<vertexCount {
        if !visited[node] {
            if dfs(node) { return true }
        }
    }

    return false
}

// MARK: - Using BFS (Kahn's Algorithm)

/// Detects cycle in a directed graph using Kahn's topological sort.
///
/// If we can topologically sort all V vertices → NO cycle (it's a DAG).
/// If some vertices remain with indegree > 0 → they form a cycle.
/// Nodes in a cycle can never have their indegree reduced to 0.
func hasCycleDirectedBFS(graph: [[Int]], vertexCount: Int) -> Bool {
    // Step 1: Compute indegree of each vertex
    var indegree = [Int](repeating: 0, count: vertexCount)
    for u in 0..<vertexCount {
        for v in graph[u] {
            indegree[v] += 1
        }
    }

    // Step 2: Enqueue all vertices with indegree 0 (no dependencies)
    var queue = Deque<Int>()
    for node in 0..<vertexCount {
        if indegree[node] == 0 {
            queue.append(node)
        }
    }

    // Step 3: Process queue — for each dequeued node, reduce indegree of neighbors
    var processedCount = 0
    while let current = queue.popFirst() {
        processedCount += 1

        for neighbor in graph[current] {
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0 {
                queue.append(neighbor)
            }
        }
    }

    // Step 4: If not all nodes were processed, remaining nodes form a cycle
    // In a DAG, every node eventually reaches indegree 0
    return processedCount != vertexCount
}

// MARK: - Example Usage

func cycleDirectedExample() {
    // Directed graph WITH cycle: 0 → 1 → 2 → 0
    var graphCycle = [[Int]](repeating: [], count: 3)
    graphCycle[0].append(1)
    graphCycle[1].append(2)
    graphCycle[2].append(0)   // Back edge creates cycle

    print("DFS - Has cycle:", hasCycleDirectedDFS(graph: graphCycle, vertexCount: 3))  // true
    print("BFS - Has cycle:", hasCycleDirectedBFS(graph: graphCycle, vertexCount: 3))  // true

    // Directed graph WITHOUT cycle (DAG): 0 → 1 → 2
    var graphDAG = [[Int]](repeating: [], count: 3)
    graphDAG[0].append(1)
    graphDAG[1].append(2)

    print("DFS - Has cycle:", hasCycleDirectedDFS(graph: graphDAG, vertexCount: 3))  // false
    print("BFS - Has cycle:", hasCycleDirectedBFS(graph: graphDAG, vertexCount: 3))  // false
}
