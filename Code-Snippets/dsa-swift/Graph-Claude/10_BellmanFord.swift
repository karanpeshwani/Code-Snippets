// MARK: - Bellman-Ford Algorithm
//
// ============================================================================
// INTUITION:
// Bellman-Ford finds shortest paths from a single source, just like Dijkstra,
// but it also handles NEGATIVE edge weights and can DETECT NEGATIVE CYCLES.
//
// Core idea: Relax ALL edges, V-1 times.
//   - "Relax" edge (u, v, w): if dist[u] + w < dist[v], update dist[v]
//   - Why V-1 times? The shortest path from source to any vertex has at most
//     V-1 edges (in a graph with V vertices). In each iteration, at least one
//     vertex gets its final shortest distance. So V-1 iterations suffice.
//
// Negative cycle detection: After V-1 iterations, do ONE MORE iteration.
//   - If any distance still decreases → NEGATIVE CYCLE exists
//   - A negative cycle means distances can decrease infinitely (no shortest path)
//
// Dijkstra vs Bellman-Ford:
//   - Dijkstra: O(E log V), but fails with negative weights
//   - Bellman-Ford: O(V * E), slower but handles negative weights
//   - Use Dijkstra when all weights are non-negative (faster)
//   - Use Bellman-Ford when negative weights exist or you need cycle detection
//
// USE CASES:
// 1. Shortest path with negative edge weights
// 2. Detecting negative weight cycles (arbitrage in currency exchange)
// 3. Distance vector routing protocol (RIP)
// 4. When Dijkstra can't be used (negative weights)
//
// USAGE PATTERNS:
// - Input: edge list (not adjacency list) — iterate all edges V-1 times
// - After V-1 relaxations, one more pass to check for negative cycles
// - If dist[u] is "infinity", skip relaxation (can't improve from unreachable node)
//
// TIME COMPLEXITY: O(V * E)
//   - Outer loop runs V-1 times
//   - Inner loop iterates over all E edges
//   - Negative cycle detection: one more pass over E edges
//   - Total: O(V * E)
//
// SPACE COMPLEXITY: O(V)
//   - Distance array: O(V)
//   - Edge list: O(E) — but that's input, not extra space
// ============================================================================

/// Edge representation for Bellman-Ford (works directly on edge list).
struct WeightedEdge {
    let from: Int
    let to: Int
    let weight: Int
}

/// Bellman-Ford shortest path from source to all vertices.
///
/// - Parameters:
///   - edges: Array of all edges in the graph
///   - source: Source vertex
///   - vertexCount: Number of vertices
/// - Returns: Distance array, or nil if a negative cycle is reachable from source
func bellmanFord(edges: [WeightedEdge], source: Int, vertexCount: Int) -> [Int]? {
    // Step 1: Initialize distances — source is 0, everything else is "infinity"
    var dist = [Int](repeating: Int.max, count: vertexCount)
    dist[source] = 0

    // Step 2: Relax all edges V-1 times
    //
    // Why V-1? In a graph with V vertices, the longest shortest path has at
    // most V-1 edges. In iteration i, we guarantee that all shortest paths
    // using at most i edges are correctly computed.
    for iteration in 0..<vertexCount - 1 {
        var updated = false

        for edge in edges {
            // Only relax if source vertex is reachable (dist != infinity)
            // If dist[from] is Int.max, adding weight could overflow
            if dist[edge.from] != Int.max {
                let newDist = dist[edge.from] + edge.weight
                if newDist < dist[edge.to] {
                    dist[edge.to] = newDist
                    updated = true
                }
            }
        }

        // Optimization: If no distance was updated in this iteration,
        // all shortest paths are finalized — no need to continue.
        if !updated { break }
    }

    // Step 3: Negative cycle detection
    //
    // One more iteration: if ANY edge can still be relaxed, it means the
    // distance can keep decreasing → negative weight cycle exists.
    for edge in edges {
        if dist[edge.from] != Int.max {
            if dist[edge.from] + edge.weight < dist[edge.to] {
                // Distance still decreasing → NEGATIVE CYCLE
                return nil
            }
        }
    }

    return dist
}

/// Convenience overload that takes tuples instead of WeightedEdge structs.
func bellmanFord(
    edgeTuples: [(from: Int, to: Int, weight: Int)],
    source: Int,
    vertexCount: Int
) -> [Int]? {
    let edges = edgeTuples.map { WeightedEdge(from: $0.from, to: $0.to, weight: $0.weight) }
    return bellmanFord(edges: edges, source: source, vertexCount: vertexCount)
}

// MARK: - Example Usage

func bellmanFordExample() {
    // Graph with negative weights (but no negative cycle):
    //   0 →(6)→ 1 →(5)→ 2
    //   0 →(7)→ 2
    //   1 →(-2)→ 3
    //   2 →(-3)→ 3
    let edges: [(from: Int, to: Int, weight: Int)] = [
        (0, 1, 6),
        (0, 2, 7),
        (1, 2, 5),
        (1, 3, -2),
        (2, 3, -3)
    ]

    if let distances = bellmanFord(edgeTuples: edges, source: 0, vertexCount: 4) {
        print("Shortest distances from 0:", distances)
        // Output: [0, 6, 7, 4]
    }

    // Graph WITH negative cycle: 0→1(1), 1→2(-3), 2→0(1)
    let cycleEdges: [(from: Int, to: Int, weight: Int)] = [
        (0, 1, 1),
        (1, 2, -3),
        (2, 0, 1)
    ]

    if bellmanFord(edgeTuples: cycleEdges, source: 0, vertexCount: 3) == nil {
        print("Negative cycle detected!")
    }
}
