// MARK: - Prim's Algorithm (Minimum Spanning Tree)
//
// ============================================================================
// INTUITION:
// A Spanning Tree of a connected graph is a subgraph that includes ALL vertices
// with exactly V-1 edges and NO cycles. A Minimum Spanning Tree (MST) is the
// spanning tree with the smallest total edge weight.
//
// Prim's is a GREEDY algorithm that grows the MST one vertex at a time:
//   1. Start from any vertex, add it to the MST
//   2. Among all edges connecting MST vertices to non-MST vertices,
//      pick the edge with MINIMUM weight
//   3. Add that edge and the new vertex to the MST
//   4. Repeat until all vertices are in the MST
//
// Think of it like growing a crystal — always extend to the nearest atom.
// It's similar to Dijkstra, but instead of tracking shortest path from source,
// we track the cheapest edge connecting each vertex to the growing MST.
//
// Prim's vs Kruskal's:
//   - Prim's: Vertex-focused, grows one tree, good for dense graphs → O(E log V)
//   - Kruskal's: Edge-focused, sorts all edges, uses Union-Find → O(E log E)
//   - Both produce an MST; the choice depends on graph density
//
// USE CASES:
// 1. Network design (minimum cost cable/pipe layout)
// 2. Cluster analysis
// 3. Approximation algorithms for NP-hard problems (TSP)
// 4. Image segmentation
//
// USAGE PATTERNS:
// - Use min-heap to efficiently get the minimum weight edge to a non-MST vertex
// - Track visited/inMST status to avoid cycles
// - Works for connected undirected weighted graphs
//
// TIME COMPLEXITY: O(E log V)
//   - Each edge inserted into heap at most once: O(E log V)
//   - Each vertex extracted from heap at most once: O(V log V)
//   - Combined: O((V + E) log V) ~ O(E log V) for connected graphs
//
// SPACE COMPLEXITY: O(V + E)
//   - Priority queue: O(E) in worst case
//   - inMST array: O(V)
//   - Key (min weight) array: O(V)
// ============================================================================

/// Result of Prim's algorithm: total MST weight and the edges included.
struct MSTResult {
    let totalWeight: Int
    let edges: [(from: Int, to: Int, weight: Int)]   // Edges in the MST
}

/// Minimal min-heap for Prim's algorithm (weight, node).
private struct PrimHeap {
    private var elements: [(weight: Int, node: Int)] = []

    var isEmpty: Bool { elements.isEmpty }

    mutating func insert(_ element: (weight: Int, node: Int)) {
        elements.append(element)
        siftUp(elements.count - 1)
    }

    mutating func popMin() -> (weight: Int, node: Int)? {
        guard !elements.isEmpty else { return nil }
        elements.swapAt(0, elements.count - 1)
        let min = elements.removeLast()
        if !elements.isEmpty { siftDown(0) }
        return min
    }

    private mutating func siftUp(_ index: Int) {
        var i = index
        while i > 0 {
            let parent = (i - 1) / 2
            if elements[i].weight < elements[parent].weight {
                elements.swapAt(i, parent)
                i = parent
            } else { break }
        }
    }

    private mutating func siftDown(_ index: Int) {
        var i = index
        let count = elements.count
        while true {
            var smallest = i
            let left = 2 * i + 1, right = 2 * i + 2
            if left < count && elements[left].weight < elements[smallest].weight { smallest = left }
            if right < count && elements[right].weight < elements[smallest].weight { smallest = right }
            if smallest == i { break }
            elements.swapAt(i, smallest)
            i = smallest
        }
    }
}

/// Finds the Minimum Spanning Tree using Prim's algorithm.
///
/// Algorithm:
/// 1. Start from vertex 0 (MST is the same regardless of starting vertex)
/// 2. Push all edges from vertex 0 into min-heap
/// 3. Extract minimum weight edge; if the destination is not yet in MST, add it
/// 4. Push all edges from the newly added vertex into the heap
/// 5. Repeat until all vertices are in MST
///
/// - Parameters:
///   - graph: Weighted undirected adjacency list, graph[u] = [(neighbor, weight)]
///   - vertexCount: Number of vertices
/// - Returns: MSTResult with total weight and edges, or nil if graph is disconnected
func primsMST(graph: [[(node: Int, weight: Int)]], vertexCount: Int) -> MSTResult? {
    var inMST = [Bool](repeating: false, count: vertexCount)
    var heap = PrimHeap()
    var totalWeight = 0
    var mstEdges = [(from: Int, to: Int, weight: Int)]()
    var edgesAdded = 0

    // Start from vertex 0
    inMST[0] = true
    for (neighbor, weight) in graph[0] {
        heap.insert((weight, neighbor))
    }

    // We also need to track which vertex the edge came from for path reconstruction
    // Using a modified approach: store (weight, to, from) in heap
    // For simplicity, let's rebuild with full edge info:
    var fullHeap = [(weight: Int, to: Int, from: Int)]()

    // Reset and use full edge tracking
    inMST = [Bool](repeating: false, count: vertexCount)
    inMST[0] = true

    // Helper heap with (weight, to, from)
    struct EdgeHeap {
        private var elements: [(w: Int, to: Int, from: Int)] = []
        var isEmpty: Bool { elements.isEmpty }

        mutating func insert(_ e: (w: Int, to: Int, from: Int)) {
            elements.append(e)
            var i = elements.count - 1
            while i > 0 {
                let p = (i - 1) / 2
                if elements[i].w < elements[p].w { elements.swapAt(i, p); i = p }
                else { break }
            }
        }

        mutating func popMin() -> (w: Int, to: Int, from: Int)? {
            guard !elements.isEmpty else { return nil }
            elements.swapAt(0, elements.count - 1)
            let min = elements.removeLast()
            if !elements.isEmpty {
                var i = 0
                while true {
                    var s = i; let l = 2*i+1, r = 2*i+2
                    if l < elements.count && elements[l].w < elements[s].w { s = l }
                    if r < elements.count && elements[r].w < elements[s].w { s = r }
                    if s == i { break }
                    elements.swapAt(i, s); i = s
                }
            }
            return min
        }
    }

    var edgeHeap = EdgeHeap()
    for (neighbor, weight) in graph[0] {
        edgeHeap.insert((weight, neighbor, 0))
    }

    while let (weight, to, from) = edgeHeap.popMin() {
        if inMST[to] { continue }    // Already in MST — skip

        // Add this vertex and edge to MST
        inMST[to] = true
        totalWeight += weight
        mstEdges.append((from, to, weight))
        edgesAdded += 1

        // Push all edges from newly added vertex
        for (neighbor, w) in graph[to] {
            if !inMST[neighbor] {
                edgeHeap.insert((w, neighbor, to))
            }
        }
    }

    // MST must have exactly V-1 edges for a connected graph
    guard edgesAdded == vertexCount - 1 else { return nil }

    return MSTResult(totalWeight: totalWeight, edges: mstEdges)
}

// MARK: - Example Usage

func primsExample() {
    // Weighted undirected graph:
    //   0 --(2)-- 1
    //   |         |
    //  (6)       (3)
    //   |         |
    //   2 --(8)-- 3
    //    \       /
    //    (5)   (7)
    //      \  /
    //       4
    let edges: [(Int, Int, Int)] = [
        (0, 1, 2), (0, 2, 6), (1, 3, 3), (2, 3, 8), (2, 4, 5), (3, 4, 7)
    ]

    var graph = [[(node: Int, weight: Int)]](repeating: [], count: 5)
    for (u, v, w) in edges {
        graph[u].append((v, w))
        graph[v].append((u, w))
    }

    if let result = primsMST(graph: graph, vertexCount: 5) {
        print("MST total weight:", result.totalWeight)   // 16
        print("MST edges:")
        for edge in result.edges {
            print("  \(edge.from) -- \(edge.to), weight: \(edge.weight)")
        }
    }
}
