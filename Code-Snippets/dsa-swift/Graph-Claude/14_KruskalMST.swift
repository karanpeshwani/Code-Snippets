// MARK: - Kruskal's Algorithm (Minimum Spanning Tree)
//
// ============================================================================
// INTUITION:
// Kruskal's is an EDGE-CENTRIC greedy algorithm for finding MST.
// While Prim's grows a single tree vertex by vertex, Kruskal's considers
// edges globally — sort ALL edges by weight, then greedily add edges that
// don't create a cycle.
//
// Algorithm:
//   1. Sort all edges by weight (ascending)
//   2. For each edge (in sorted order):
//      - If the two endpoints are in DIFFERENT components → add edge to MST
//      - If they're in the SAME component → skip (would create a cycle)
//   3. Stop when we have V-1 edges (MST is complete)
//
// "Different components" check is done efficiently using Union-Find (DSU).
// Union-Find's find() tells us if two nodes share a root; if not, union() merges them.
//
// Why it works: By always picking the lightest edge that doesn't create a cycle,
// we guarantee minimum total weight. This is the CUT PROPERTY of MSTs — the
// lightest edge crossing any cut must be in the MST.
//
// Prim's vs Kruskal's:
//   - Prim's: O(E log V), vertex-centric, better for dense graphs
//   - Kruskal's: O(E log E), edge-centric, better for sparse graphs
//   - Kruskal's is simpler to implement (sort + union-find)
//
// PREREQUISITE: Disjoint Set Union (Union-Find) data structure.
//
// USE CASES:
// 1. Network design (minimum wiring/piping)
// 2. Clustering (remove heaviest edges to get k clusters)
// 3. Approximating TSP
// 4. Image segmentation
//
// USAGE PATTERNS:
// - Sort edges, iterate with Union-Find
// - If graph given as adjacency list, extract edges first
// - Duplicate edges (u,v) and (v,u) are harmless — DSU auto-skips duplicates
//
// TIME COMPLEXITY: O(E log E) or equivalently O(E log V)
//   - Sorting edges: O(E log E) = O(E log V) since E ≤ V²
//   - Union-Find operations: O(E * α(V)) ≈ O(E) — nearly constant per op
//   - Dominated by sorting: O(E log E)
//
// SPACE COMPLEXITY: O(V + E)
//   - Edge list: O(E)
//   - DSU parent + rank/size arrays: O(V)
// ============================================================================

// MARK: - DSU for Kruskal's (self-contained)

/// Lightweight DSU with path compression and union by rank for Kruskal's.
private class KruskalDSU {
    var parent: [Int]
    var rank: [Int]

    init(_ n: Int) {
        parent = Array(0..<n)
        rank = [Int](repeating: 0, count: n)
    }

    func find(_ x: Int) -> Int {
        if parent[x] != x {
            parent[x] = find(parent[x])
        }
        return parent[x]
    }

    /// Returns true if union was performed (different sets), false if already connected.
    func union(_ x: Int, _ y: Int) -> Bool {
        let rx = find(x), ry = find(y)
        if rx == ry { return false }

        if rank[rx] < rank[ry] { parent[rx] = ry }
        else if rank[rx] > rank[ry] { parent[ry] = rx }
        else { parent[ry] = rx; rank[rx] += 1 }

        return true
    }
}

/// Kruskal's MST edge.
struct KruskalEdge: Comparable {
    let from: Int
    let to: Int
    let weight: Int

    // Sort by weight for greedy selection
    static func < (lhs: KruskalEdge, rhs: KruskalEdge) -> Bool {
        return lhs.weight < rhs.weight
    }
}

/// Finds MST using Kruskal's algorithm.
///
/// - Parameters:
///   - edges: All edges in the graph (undirected)
///   - vertexCount: Number of vertices
/// - Returns: (total MST weight, edges in MST), or nil if graph is disconnected
func kruskalMST(edges: [KruskalEdge], vertexCount: Int) -> (totalWeight: Int, mstEdges: [KruskalEdge])? {
    // Step 1: Sort all edges by weight (ascending)
    let sortedEdges = edges.sorted()

    // Step 2: Initialize Union-Find
    let dsu = KruskalDSU(vertexCount)

    var mstEdges = [KruskalEdge]()
    var totalWeight = 0

    // Step 3: Greedily add edges that connect different components
    for edge in sortedEdges {
        // Check if endpoints are in different components
        if dsu.union(edge.from, edge.to) {
            // They were in different sets → edge is safe to add (no cycle)
            mstEdges.append(edge)
            totalWeight += edge.weight

            // MST has exactly V-1 edges — stop early
            if mstEdges.count == vertexCount - 1 {
                break
            }
        }
        // If union returns false, they're already connected → skip (would create cycle)
    }

    // Check if MST is complete (graph must be connected)
    guard mstEdges.count == vertexCount - 1 else { return nil }

    return (totalWeight, mstEdges)
}

/// Convenience: build edge list from adjacency list.
func extractEdges(graph: [[(node: Int, weight: Int)]], vertexCount: Int) -> [KruskalEdge] {
    var edges = [KruskalEdge]()
    var seen = Set<String>()   // Avoid duplicate edges for undirected graph

    for u in 0..<vertexCount {
        for (v, w) in graph[u] {
            let key = "\(min(u, v))-\(max(u, v))"
            if !seen.contains(key) {
                seen.insert(key)
                edges.append(KruskalEdge(from: u, to: v, weight: w))
            }
        }
    }

    return edges
}

// MARK: - Example Usage

func kruskalExample() {
    // Same graph as Prim's example:
    //   0 --(2)-- 1
    //   |         |
    //  (6)       (3)
    //   |         |
    //   2 --(8)-- 3
    //    \       /
    //    (5)   (7)
    //      \  /
    //       4
    let edges = [
        KruskalEdge(from: 0, to: 1, weight: 2),
        KruskalEdge(from: 0, to: 2, weight: 6),
        KruskalEdge(from: 1, to: 3, weight: 3),
        KruskalEdge(from: 2, to: 3, weight: 8),
        KruskalEdge(from: 2, to: 4, weight: 5),
        KruskalEdge(from: 3, to: 4, weight: 7)
    ]

    if let result = kruskalMST(edges: edges, vertexCount: 5) {
        print("MST total weight:", result.totalWeight)   // 16
        print("MST edges (in order added):")
        for edge in result.mstEdges {
            print("  \(edge.from) -- \(edge.to), weight: \(edge.weight)")
        }
        // Expected edges (sorted by weight):
        // 0--1 (2), 1--3 (3), 2--4 (5), 0--2 (6)
    }
}
