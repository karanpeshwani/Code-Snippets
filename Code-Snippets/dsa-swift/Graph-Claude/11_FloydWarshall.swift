// MARK: - Floyd-Warshall Algorithm
//
// ============================================================================
// INTUITION:
// Floyd-Warshall finds shortest paths between ALL PAIRS of vertices.
// Unlike Dijkstra (single source) and Bellman-Ford (single source), this
// computes dist[i][j] for every pair (i, j) simultaneously.
//
// Core idea (Dynamic Programming):
//   For each intermediate vertex k (0 to V-1), check if going through k
//   gives a shorter path from i to j than the current best:
//     dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
//
//   Think of it as: "Can I find a shortcut from i to j by passing through k?"
//
// The triple nested loop (k, i, j) considers ALL possible intermediate stops.
// After iteration k, dist[i][j] = shortest path from i to j using only
// vertices {0, 1, ..., k} as intermediates.
//
// Negative cycle detection: If dist[i][i] < 0 for any vertex i, a negative
// cycle exists (the shortest "path" from i to itself is negative).
//
// Dijkstra vs Bellman-Ford vs Floyd-Warshall:
//   - Dijkstra: SSSP, O(E log V), non-negative weights only
//   - Bellman-Ford: SSSP, O(VE), handles negative weights
//   - Floyd-Warshall: All-pairs, O(V³), handles negative weights
//   - For all-pairs with non-negative weights: running Dijkstra from each vertex
//     gives O(V * E log V), which beats O(V³) for sparse graphs
//
// USE CASES:
// 1. All-pairs shortest path (distance between every pair of cities)
// 2. Transitive closure (can i reach j?)
// 3. Detecting negative cycles
// 4. Finding the diameter of a graph
// 5. Shortest paths in dense graphs
//
// USAGE PATTERNS:
// - Input: Adjacency MATRIX (not adjacency list)
// - dist[i][i] = 0, dist[i][j] = weight for direct edge, INF otherwise
// - k is the OUTERMOST loop (critical — this is the DP state)
//
// TIME COMPLEXITY: O(V³)
//   - Three nested loops, each iterating V times
//   - Cannot be improved — every pair must be checked with every intermediate
//
// SPACE COMPLEXITY: O(V²)
//   - 2D distance matrix of size V × V
//   - In-place update (no extra matrix needed beyond the distance matrix)
// ============================================================================

/// Floyd-Warshall all-pairs shortest path algorithm.
///
/// - Parameter costMatrix: V×V matrix where costMatrix[i][j] = edge weight from i to j.
///   Use Int.max / 2 for no direct edge (divided by 2 to prevent overflow on addition).
/// - Returns: V×V distance matrix, or nil if a negative cycle exists
func floydWarshall(_ costMatrix: [[Int]]) -> [[Int]]? {
    let v = costMatrix.count
    var dist = costMatrix   // Work on a copy

    // DP: Try every vertex as an intermediate point
    // CRITICAL: k must be the outermost loop
    //   - After processing k=0, dist[i][j] = shortest path using only vertex 0 as intermediate
    //   - After processing k=1, uses vertices {0, 1}
    //   - After all k, uses all vertices → final answer
    for k in 0..<v {
        for i in 0..<v {
            for j in 0..<v {
                // Skip if either segment is unreachable (prevent overflow)
                if dist[i][k] != Int.max / 2 && dist[k][j] != Int.max / 2 {
                    // Can we get a shorter path from i to j by going through k?
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
                }
            }
        }
    }

    // Negative cycle detection: if shortest path from i to itself is negative
    for i in 0..<v {
        if dist[i][i] < 0 {
            return nil   // Negative cycle exists
        }
    }

    return dist
}

/// Builds a cost matrix from an edge list.
/// Initializes diagonal to 0, missing edges to INF.
func buildCostMatrix(
    vertexCount: Int,
    edges: [(from: Int, to: Int, weight: Int)],
    directed: Bool = true
) -> [[Int]] {
    let INF = Int.max / 2   // Use half of max to prevent overflow during addition
    var matrix = [[Int]](repeating: [Int](repeating: INF, count: vertexCount), count: vertexCount)

    // Distance from a node to itself is 0
    for i in 0..<vertexCount {
        matrix[i][i] = 0
    }

    // Fill in edge weights
    for (u, v, w) in edges {
        matrix[u][v] = w
        if !directed {
            matrix[v][u] = w
        }
    }

    return matrix
}

// MARK: - Transitive Closure (Can i reach j?)
//
// Variant of Floyd-Warshall using boolean matrix instead of distances.
// reach[i][j] = true if there's a path from i to j.

/// Computes transitive closure: reach[i][j] = true if j is reachable from i.
func transitiveClosure(adjMatrix: [[Bool]]) -> [[Bool]] {
    let v = adjMatrix.count
    var reach = adjMatrix

    for k in 0..<v {
        for i in 0..<v {
            for j in 0..<v {
                // i can reach j if: i already reaches j, OR i reaches k AND k reaches j
                reach[i][j] = reach[i][j] || (reach[i][k] && reach[k][j])
            }
        }
    }

    return reach
}

// MARK: - Example Usage

func floydWarshallExample() {
    // Directed weighted graph:
    //   0 →(3)→ 1
    //   0 →(7)→ 2
    //   1 →(2)→ 2
    //   2 →(1)→ 3
    //   3 →(6)→ 0
    let edges: [(from: Int, to: Int, weight: Int)] = [
        (0, 1, 3), (0, 2, 7), (1, 2, 2), (2, 3, 1), (3, 0, 6)
    ]

    let costMatrix = buildCostMatrix(vertexCount: 4, edges: edges)

    if let distances = floydWarshall(costMatrix) {
        print("All-pairs shortest distances:")
        for row in distances {
            let formatted = row.map { $0 == Int.max / 2 ? "INF" : "\($0)" }
            print(formatted)
        }
        // Expected:
        // [0, 3, 5, 6]
        // [9, 0, 2, 3]
        // [7, 10, 0, 1]
        // [6, 9, 11, 0]
    }
}
