import Collections

// MARK: - Topological Sort
//
// ============================================================================
// INTUITION:
// Topological sort produces a LINEAR ordering of vertices in a Directed Acyclic
// Graph (DAG) such that for every directed edge u → v, vertex u comes before v.
// Think of it as: "What order should I complete tasks if some tasks depend on others?"
//
// Two approaches:
// (a) Kahn's Algorithm (BFS + Queue): Start with nodes that have no dependencies
//     (indegree 0), process them, reduce indegrees of their neighbors, repeat.
//     Naturally produces the ordering left-to-right.
//
// (b) DFS + Stack: Do DFS; when a node finishes (all descendants explored),
//     push it onto a stack. The stack reversal gives topological order.
//     Intuition: A node should appear AFTER all nodes it depends on, so we
//     add it to the result only after all its descendants are processed.
//
// IMPORTANT: Topological sort is ONLY valid for DAGs (Directed Acyclic Graphs).
// If there's a cycle, topological ordering is impossible.
//
// USE CASES:
// 1. Task scheduling with dependencies (build systems, course prerequisites)
// 2. Compilation order of source files
// 3. Spreadsheet cell evaluation order
// 4. Package dependency resolution (npm, pip, etc.)
// 5. Data pipeline execution order
//
// USAGE PATTERNS:
// - Kahn's (BFS): Also useful for cycle detection — if result has < V nodes, cycle exists
// - DFS: More natural for problems that need reverse post-order
// - Both produce valid topological orderings; multiple valid orderings may exist
//
// TIME COMPLEXITY: O(V + E)
//   - Each vertex and edge processed exactly once in both approaches
//
// SPACE COMPLEXITY: O(V)
//   - Kahn's: indegree array O(V) + queue O(V)
//   - DFS: visited array O(V) + recursion stack O(V) + result stack O(V)
// ============================================================================

// MARK: - Kahn's Algorithm (BFS)

/// Topological sort using Kahn's algorithm (BFS with indegree tracking).
///
/// Algorithm:
/// 1. Calculate indegree of all vertices
/// 2. Add all vertices with indegree 0 to the queue
/// 3. Process queue: for each vertex, add to result, reduce neighbor indegrees
/// 4. If a neighbor's indegree becomes 0, add to queue
///
/// - Returns: Topologically sorted array, or empty array if cycle exists
func topologicalSortKahns(graph: [[Int]], vertexCount: Int) -> [Int] {
    // Step 1: Compute indegree (number of incoming edges for each vertex)
    var indegree = [Int](repeating: 0, count: vertexCount)
    for u in 0..<vertexCount {
        for v in graph[u] {
            indegree[v] += 1
        }
    }

    // Step 2: Start with all vertices that have no prerequisites (indegree = 0)
    var queue = Deque<Int>()
    for node in 0..<vertexCount {
        if indegree[node] == 0 {
            queue.append(node)
        }
    }

    // Step 3: BFS — process nodes layer by layer
    var result = [Int]()
    while let current = queue.popFirst() {
        result.append(current)

        // "Remove" this node from the graph by decrementing neighbor indegrees
        for neighbor in graph[current] {
            indegree[neighbor] -= 1
            if indegree[neighbor] == 0 {
                queue.append(neighbor)    // No more dependencies — ready to process
            }
        }
    }

    // If result doesn't contain all vertices, graph has a cycle
    return result.count == vertexCount ? result : []
}

// MARK: - DFS-based Topological Sort

/// Topological sort using DFS and a stack.
///
/// Algorithm:
/// 1. Run DFS from each unvisited node
/// 2. After exploring ALL neighbors of a node (post-order), push it to stack
/// 3. The stack (reversed) gives topological order
///
/// Why it works: A node is pushed ONLY after all reachable nodes from it are
/// already pushed. So when we reverse, prerequisites come first.
///
/// - Returns: Topologically sorted array (assumes DAG — no cycle detection here)
func topologicalSortDFS(graph: [[Int]], vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var stack = [Int]()    // Nodes pushed in reverse topological order

    func dfs(_ node: Int) {
        visited[node] = true

        // First, recursively visit all neighbors (dependencies)
        for neighbor in graph[node] {
            if !visited[neighbor] {
                dfs(neighbor)
            }
        }

        // Post-order: push AFTER all descendants are processed
        // This ensures all nodes reachable from 'node' are already in the stack
        stack.append(node)
    }

    // Handle disconnected components
    for node in 0..<vertexCount {
        if !visited[node] {
            dfs(node)
        }
    }

    // Reverse gives topological order (or just read stack from top)
    return stack.reversed()
}

// MARK: - Example Usage

func topologicalSortExample() {
    // DAG representing course prerequisites:
    //   5 → 0, 5 → 2, 4 → 0, 4 → 1, 2 → 3, 3 → 1
    //
    //   5 → 0 ← 4
    //   ↓       ↓
    //   2 → 3 → 1
    var graph = [[Int]](repeating: [], count: 6)
    graph[5].append(0)
    graph[5].append(2)
    graph[4].append(0)
    graph[4].append(1)
    graph[2].append(3)
    graph[3].append(1)

    let kahns = topologicalSortKahns(graph: graph, vertexCount: 6)
    print("Kahn's topological sort:", kahns)
    // One valid output: [4, 5, 0, 2, 3, 1]

    let dfsBased = topologicalSortDFS(graph: graph, vertexCount: 6)
    print("DFS topological sort:", dfsBased)
    // One valid output: [5, 4, 2, 3, 1, 0]
}
