import Collections

// MARK: - Breadth First Search (BFS)
//
// ============================================================================
// INTUITION:
// BFS explores a graph level by level, starting from a source node.
// It uses a queue (FIFO) to process nodes in the order they are discovered.
// Think of it like ripples spreading outward from a stone dropped in water —
// all nodes at distance 1 are visited before nodes at distance 2, and so on.
//
// USE CASES:
// 1. Shortest path in unweighted graphs (each edge has weight 1)
// 2. Level-order traversal of trees/graphs
// 3. Finding connected components
// 4. Web crawlers (exploring pages layer by layer)
// 5. Social network: finding people within k connections
// 6. Puzzle solving (e.g., shortest moves in a board game)
//
// USAGE PATTERNS:
// - When you need the SHORTEST path in an UNWEIGHTED graph → BFS
// - When you need to explore neighbors before going deeper → BFS
// - When the solution is likely near the root/source → BFS
//
// TIME COMPLEXITY: O(V + E)
//   - Each vertex is enqueued and dequeued exactly once → O(V)
//   - For each vertex, we iterate over its adjacency list → total O(E) for directed,
//     O(2E) for undirected (each edge counted from both endpoints)
//   - Combined: O(V + E)
//
// SPACE COMPLEXITY: O(V)
//   - Queue can hold at most O(V) nodes (in worst case, all nodes at one level)
//   - Visited array: O(V)
//   - Adjacency list storage: O(V + E) — but that's input, not extra space
// ============================================================================

/// BFS traversal of a graph represented as an adjacency list.
/// - Parameters:
///   - graph: Adjacency list where graph[u] contains neighbors of u
///   - source: Starting node for BFS
///   - vertexCount: Total number of vertices (0-indexed)
/// - Returns: Array of nodes in BFS traversal order
func bfs(graph: [[Int]], source: Int, vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var result = [Int]()

    // Deque from Swift Collections — O(1) append and popFirst
    var queue = Deque<Int>()

    // Start BFS from source: mark visited BEFORE enqueuing (prevents duplicates)
    visited[source] = true
    queue.append(source)

    while let current = queue.popFirst() {
        result.append(current)

        // Explore all neighbors of current node
        for neighbor in graph[current] {
            if !visited[neighbor] {
                visited[neighbor] = true   // Mark visited when enqueuing, NOT when dequeuing
                queue.append(neighbor)
            }
        }
    }

    return result
}

/// BFS for disconnected graphs — handles multiple components.
/// Iterates over all vertices; if unvisited, starts a new BFS from that vertex.
/// - Parameters:
///   - graph: Adjacency list
///   - vertexCount: Total number of vertices
/// - Returns: Array of nodes in BFS traversal order (all components)
func bfsDisconnected(graph: [[Int]], vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var result = [Int]()
    var queue = Deque<Int>()

    for node in 0..<vertexCount {
        if !visited[node] {
            // New component found — start BFS from this node
            visited[node] = true
            queue.append(node)

            while let current = queue.popFirst() {
                result.append(current)
                for neighbor in graph[current] {
                    if !visited[neighbor] {
                        visited[neighbor] = true
                        queue.append(neighbor)
                    }
                }
            }
        }
    }

    return result
}

// MARK: - BFS Shortest Path in Unweighted Graph
//
// BFS naturally finds the shortest path (minimum edges) from source to every
// reachable node. The distance array stores the number of edges from source.

/// Finds shortest distance (in terms of edges) from source to all other nodes.
/// - Returns: Distance array where dist[i] = shortest edge count from source to i, or -1 if unreachable
func bfsShortestPath(graph: [[Int]], source: Int, vertexCount: Int) -> [Int] {
    var dist = [Int](repeating: -1, count: vertexCount)
    var queue = Deque<Int>()

    dist[source] = 0
    queue.append(source)

    while let current = queue.popFirst() {
        for neighbor in graph[current] {
            // Only update if not visited (first visit = shortest distance)
            if dist[neighbor] == -1 {
                dist[neighbor] = dist[current] + 1
                queue.append(neighbor)
            }
        }
    }

    return dist
}

// MARK: - Build Adjacency List Helper

/// Builds an undirected adjacency list from edge pairs.
func buildUndirectedGraph(vertexCount: Int, edges: [(Int, Int)]) -> [[Int]] {
    var graph = [[Int]](repeating: [], count: vertexCount)
    for (u, v) in edges {
        graph[u].append(v)
        graph[v].append(u)
    }
    return graph
}

// MARK: - Example Usage

func bfsExample() {
    // Graph:
    //   0 -- 1 -- 3
    //   |    |
    //   2    4
    let edges = [(0, 1), (0, 2), (1, 3), (1, 4)]
    let graph = buildUndirectedGraph(vertexCount: 5, edges: edges)

    let traversal = bfs(graph: graph, source: 0, vertexCount: 5)
    print("BFS traversal from 0:", traversal)
    // Output: [0, 1, 2, 3, 4]

    let distances = bfsShortestPath(graph: graph, source: 0, vertexCount: 5)
    print("Shortest distances from 0:", distances)
    // Output: [0, 1, 1, 2, 2]
}
