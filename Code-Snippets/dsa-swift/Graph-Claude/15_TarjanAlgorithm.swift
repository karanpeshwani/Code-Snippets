// MARK: - Tarjan's Algorithm (Bridges & Articulation Points)
//
// ============================================================================
// INTUITION:
// Tarjan's algorithm identifies critical connections in a graph using a single
// DFS traversal. It tracks two key values per node:
//
//   - disc[u] (discovery time): When was node u first visited? (incrementing timer)
//   - low[u]: The minimum discovery time reachable from u's subtree through
//     back edges. This tells us: "how far back can I reach without using the
//     edge I came from?"
//
// ── BRIDGES (Critical Edges) ──
// An edge (u, v) is a bridge if removing it disconnects the graph.
//
// Condition: Edge (u → v) is a bridge if low[v] > disc[u]
//   - This means: from v's subtree, you CANNOT reach u or any ancestor of u
//     through any back edge. So removing (u, v) disconnects v's subtree.
//   - If low[v] ≤ disc[u], there's a back edge from v's subtree to u or above,
//     so the edge is NOT a bridge (alternative path exists).
//
// ── ARTICULATION POINTS (Critical Vertices) ──
// A vertex u is an articulation point if removing it disconnects the graph.
//
// Two cases:
//   1. Root of DFS tree: u is an articulation point if it has 2+ children
//      (removing root splits children into separate components)
//   2. Non-root: u is an articulation point if there exists a child v where
//      low[v] >= disc[u] (v's subtree can't reach above u without going through u)
//
// Note the difference: Bridges use low[v] > disc[u] (strict).
// Articulation points use low[v] >= disc[u] (non-strict).
// Because even if v can reach u itself (low[v] == disc[u]), removing u still
// disconnects v's subtree.
//
// USE CASES:
// 1. Finding critical connections in networks (single points of failure)
// 2. Network reliability analysis
// 3. Finding biconnected components
// 4. LeetCode 1192: Critical Connections in a Network
//
// USAGE PATTERNS:
// - Single DFS traversal — compute disc[] and low[] as you go
// - Bridges: check condition at edge (u, v) where v is DFS child
// - Articulation points: check condition at each node after processing children
//
// TIME COMPLEXITY: O(V + E)
//   - Single DFS traversal visiting each vertex and edge once
//
// SPACE COMPLEXITY: O(V)
//   - disc[], low[], visited[]: O(V) each
//   - Recursion stack: O(V) worst case
// ============================================================================

// MARK: - Bridges in Graph (Critical Connections)

/// Finds all bridges (critical edges) in an undirected graph using Tarjan's algorithm.
///
/// A bridge is an edge whose removal increases the number of connected components.
///
/// - Parameters:
///   - graph: Undirected adjacency list
///   - vertexCount: Number of vertices
/// - Returns: Array of bridge edges as (u, v) pairs
func findBridges(graph: [[Int]], vertexCount: Int) -> [(Int, Int)] {
    var disc = [Int](repeating: -1, count: vertexCount)   // Discovery time
    var low = [Int](repeating: -1, count: vertexCount)    // Lowest reachable discovery time
    var timer = 0
    var bridges = [(Int, Int)]()

    /// DFS to compute disc[] and low[] and identify bridges.
    func dfs(_ node: Int, parent: Int) {
        disc[node] = timer
        low[node] = timer
        timer += 1

        for neighbor in graph[node] {
            if disc[neighbor] == -1 {
                // Tree edge — neighbor not yet visited
                dfs(neighbor, parent: node)

                // After DFS returns, update low[node] with child's low value
                // (child may have found a back edge to an ancestor)
                low[node] = min(low[node], low[neighbor])

                // BRIDGE CHECK: If child can't reach node or above → bridge
                // low[neighbor] > disc[node] means no back edge from neighbor's
                // subtree can reach node or any ancestor of node
                if low[neighbor] > disc[node] {
                    bridges.append((node, neighbor))
                }
            } else if neighbor != parent {
                // Back edge — neighbor already visited (and not parent)
                // Update low[node]: we can reach as far back as disc[neighbor]
                low[node] = min(low[node], disc[neighbor])
            }
            // If neighbor == parent: skip (the edge we came from, not a back edge)
        }
    }

    // Handle disconnected components
    for node in 0..<vertexCount {
        if disc[node] == -1 {
            dfs(node, parent: -1)
        }
    }

    return bridges
}

// MARK: - Articulation Points (Cut Vertices)

/// Finds all articulation points (cut vertices) in an undirected graph.
///
/// An articulation point is a vertex whose removal increases the number of
/// connected components.
///
/// - Parameters:
///   - graph: Undirected adjacency list
///   - vertexCount: Number of vertices
/// - Returns: Set of articulation point vertex indices
func findArticulationPoints(graph: [[Int]], vertexCount: Int) -> Set<Int> {
    var disc = [Int](repeating: -1, count: vertexCount)
    var low = [Int](repeating: -1, count: vertexCount)
    var timer = 0
    var articulationPoints = Set<Int>()

    func dfs(_ node: Int, parent: Int) {
        disc[node] = timer
        low[node] = timer
        timer += 1
        var childCount = 0    // Number of DFS tree children (for root check)

        for neighbor in graph[node] {
            if disc[neighbor] == -1 {
                // Tree edge
                childCount += 1
                dfs(neighbor, parent: node)

                low[node] = min(low[node], low[neighbor])

                // CASE 1: Root of DFS tree with 2+ children
                // If root has ≥2 children in DFS tree, removing it disconnects them
                if parent == -1 && childCount > 1 {
                    articulationPoints.insert(node)
                }

                // CASE 2: Non-root vertex where child can't reach above
                // low[neighbor] >= disc[node] means neighbor's subtree can't
                // reach any ancestor of node (or node itself) without going through node
                // Note: >= (not >), because even reaching node itself means
                //        removing node disconnects the subtree
                if parent != -1 && low[neighbor] >= disc[node] {
                    articulationPoints.insert(node)
                }
            } else if neighbor != parent {
                // Back edge
                low[node] = min(low[node], disc[neighbor])
            }
        }
    }

    for node in 0..<vertexCount {
        if disc[node] == -1 {
            dfs(node, parent: -1)
        }
    }

    return articulationPoints
}

// MARK: - Tarjan's SCC (Strongly Connected Components)
//
// Tarjan's can also find SCCs in directed graphs using a single DFS.
// Unlike Kosaraju's (2 DFS passes), Tarjan's uses a stack to track
// the current SCC being formed.

/// Finds all SCCs in a directed graph using Tarjan's algorithm (1 DFS pass).
///
/// Maintains a stack of nodes in the current DFS path. When a node's low value
/// equals its discovery time, it's the root of an SCC — pop all nodes above it
/// from the stack to form the SCC.
func tarjanSCC(graph: [[Int]], vertexCount: Int) -> [[Int]] {
    var disc = [Int](repeating: -1, count: vertexCount)
    var low = [Int](repeating: -1, count: vertexCount)
    var onStack = [Bool](repeating: false, count: vertexCount)
    var stack = [Int]()
    var timer = 0
    var allSCCs = [[Int]]()

    func dfs(_ node: Int) {
        disc[node] = timer
        low[node] = timer
        timer += 1
        stack.append(node)
        onStack[node] = true

        for neighbor in graph[node] {
            if disc[neighbor] == -1 {
                // Tree edge
                dfs(neighbor)
                low[node] = min(low[node], low[neighbor])
            } else if onStack[neighbor] {
                // Back edge to a node still on the stack (in current SCC path)
                low[node] = min(low[node], disc[neighbor])
            }
            // Cross edge to already-processed SCC: ignore
        }

        // If low[node] == disc[node], node is the ROOT of an SCC
        // Pop everything above it (including itself) — that's the SCC
        if low[node] == disc[node] {
            var scc = [Int]()
            while true {
                let top = stack.removeLast()
                onStack[top] = false
                scc.append(top)
                if top == node { break }
            }
            allSCCs.append(scc)
        }
    }

    for node in 0..<vertexCount {
        if disc[node] == -1 {
            dfs(node)
        }
    }

    return allSCCs
}

// MARK: - Example Usage

func tarjanExample() {
    // Bridges example:
    //   0 -- 1 -- 2
    //        |    |
    //        4 -- 3
    //   Edge 0-1 is a bridge (removing it disconnects 0)
    var bridgeGraph = [[Int]](repeating: [], count: 5)
    let bridgeEdges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 1)]
    for (u, v) in bridgeEdges {
        bridgeGraph[u].append(v)
        bridgeGraph[v].append(u)
    }

    let bridges = findBridges(graph: bridgeGraph, vertexCount: 5)
    print("Bridges:", bridges)   // [(0, 1)]

    // Articulation Points example (same graph):
    // Vertex 1 is an articulation point (removing it disconnects 0 from rest)
    let artPoints = findArticulationPoints(graph: bridgeGraph, vertexCount: 5)
    print("Articulation points:", artPoints)   // {1}

    // Tarjan's SCC example (directed graph):
    //   0 → 1 → 2 → 0 (cycle = SCC), 2 → 3 → 4
    var directedGraph = [[Int]](repeating: [], count: 5)
    directedGraph[0].append(1)
    directedGraph[1].append(2)
    directedGraph[2].append(0)
    directedGraph[2].append(3)
    directedGraph[3].append(4)

    let sccs = tarjanSCC(graph: directedGraph, vertexCount: 5)
    print("SCCs:", sccs)
    // Expected: [[4], [3], [2, 1, 0]]
}
