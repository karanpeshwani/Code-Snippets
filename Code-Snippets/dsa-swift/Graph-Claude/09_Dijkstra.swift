import Collections

// MARK: - Dijkstra's Algorithm
//
// ============================================================================
// INTUITION:
// Dijkstra's finds the shortest path from a SINGLE SOURCE to ALL other nodes
// in a graph with NON-NEGATIVE edge weights.
//
// Greedy approach: Always process the unvisited node with the smallest known
// distance. When we process a node, its distance is finalized (can never improve).
// For each processed node, "relax" its edges — if going through this node
// offers a shorter path to a neighbor, update the neighbor's distance.
//
// Why Priority Queue (Min-Heap)?
// A regular queue (BFS) doesn't work because edges have different weights.
// BFS assumes all edges have weight 1. With weighted edges, we need to always
// process the node with the current MINIMUM distance — that's a min-heap.
//
// CRITICAL: Dijkstra FAILS with negative edge weights!
// With negative weights, a "finalized" node's distance could later decrease,
// violating the greedy assumption. Use Bellman-Ford instead.
//
// USE CASES:
// 1. GPS navigation / shortest route finding
// 2. Network routing protocols (OSPF)
// 3. Shortest path in weighted graphs (games, maps)
// 4. Social network analysis (degrees of separation with weights)
//
// USAGE PATTERNS:
// - Graph with non-negative weights → Dijkstra
// - Need shortest path from one source to all nodes → Dijkstra (SSSP)
// - Negative weights → Bellman-Ford
// - All pairs shortest path → Floyd-Warshall
//
// TIME COMPLEXITY: O(E log V)
//   - Each vertex extracted from heap at most once: O(V log V)
//   - Each edge causes at most one heap insertion: O(E log V)
//   - Combined: O((V + E) log V) ~ O(E log V) for connected graphs
//
// SPACE COMPLEXITY: O(V + E)
//   - Distance array: O(V)
//   - Priority queue: O(E) worst case (may have duplicate entries)
//   - Adjacency list: O(V + E)
// ============================================================================

// MARK: - Dijkstra using Min-Heap (Priority Queue)

/// Finds shortest distances from source to all vertices using Dijkstra's algorithm.
///
/// Uses Heap from Swift Collections as a min-heap.
/// Stores (distance, node) pairs — sorted by distance.
///
/// - Parameters:
///   - graph: Weighted adjacency list, graph[u] = [(neighbor, weight)]
///   - source: Starting vertex
///   - vertexCount: Total number of vertices
/// - Returns: Array where dist[i] = shortest distance from source to i (Int.max if unreachable)
func dijkstra(graph: [[(node: Int, weight: Int)]], source: Int, vertexCount: Int) -> [Int] {
    // Distance array — initialized to "infinity"
    var dist = [Int](repeating: Int.max, count: vertexCount)
    dist[source] = 0

    // Min-heap: (distance, node) — always process the closest unfinalized node
    // Heap from Swift Collections provides O(log n) insert and extractMin
    var minHeap = Heap<(dist: Int, node: Int)>(comparator: { $0.dist < $1.dist })
    minHeap.insert((0, source))

    while let (currentDist, currentNode) = minHeap.popMin() {
        // Skip stale entries: if we already found a shorter path, this entry is outdated
        // This is the "lazy deletion" approach — cheaper than decrease-key
        if currentDist > dist[currentNode] { continue }

        // Relax all edges from current node
        for (neighbor, weight) in graph[currentNode] {
            let newDist = currentDist + weight
            if newDist < dist[neighbor] {
                dist[neighbor] = newDist
                minHeap.insert((newDist, neighbor))
                // Note: We insert a new entry rather than updating the existing one.
                // Old entries become stale and are skipped via the check above.
            }
        }
    }

    return dist
}

// MARK: - Dijkstra with Path Reconstruction

/// Dijkstra's algorithm that also tracks the shortest path to each vertex.
///
/// Uses a parent array to remember "from which node did I arrive here with minimum cost".
/// After computing shortest distances, backtrack from destination to source via parents.
///
/// - Returns: Tuple of (distances array, parent array for path reconstruction)
func dijkstraWithPath(
    graph: [[(node: Int, weight: Int)]],
    source: Int,
    vertexCount: Int
) -> (dist: [Int], parent: [Int]) {
    var dist = [Int](repeating: Int.max, count: vertexCount)
    var parent = [Int](repeating: -1, count: vertexCount)   // -1 = no parent
    dist[source] = 0

    var minHeap = Heap<(dist: Int, node: Int)>(comparator: { $0.dist < $1.dist })
    minHeap.insert((0, source))

    while let (currentDist, currentNode) = minHeap.popMin() {
        if currentDist > dist[currentNode] { continue }

        for (neighbor, weight) in graph[currentNode] {
            let newDist = currentDist + weight
            if newDist < dist[neighbor] {
                dist[neighbor] = newDist
                parent[neighbor] = currentNode   // Remember where we came from
                minHeap.insert((newDist, neighbor))
            }
        }
    }

    return (dist, parent)
}

/// Reconstructs the shortest path from source to destination using the parent array.
/// Returns the path as an array of vertices, or empty array if unreachable.
func reconstructPath(parent: [Int], source: Int, destination: Int) -> [Int] {
    if parent[destination] == -1 && destination != source {
        return []   // Unreachable
    }

    var path = [Int]()
    var current = destination

    // Backtrack from destination to source using parent pointers
    while current != -1 {
        path.append(current)
        current = parent[current]
    }

    return path.reversed()
}

// MARK: - Simple Heap Implementation (if Swift Collections Heap unavailable)
//
// Swift Collections' Heap doesn't have a comparator-based init in all versions.
// Here's a minimal min-heap for (distance, node) pairs.

struct MinHeap {
    private var elements: [(dist: Int, node: Int)] = []

    var isEmpty: Bool { elements.isEmpty }

    mutating func insert(_ element: (dist: Int, node: Int)) {
        elements.append(element)
        siftUp(elements.count - 1)
    }

    mutating func popMin() -> (dist: Int, node: Int)? {
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
            if elements[i].dist < elements[parent].dist {
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
            let left = 2 * i + 1
            let right = 2 * i + 2
            if left < count && elements[left].dist < elements[smallest].dist { smallest = left }
            if right < count && elements[right].dist < elements[smallest].dist { smallest = right }
            if smallest == i { break }
            elements.swapAt(i, smallest)
            i = smallest
        }
    }
}

// MARK: - Dijkstra using custom MinHeap (guaranteed to compile without Collections)

func dijkstraCustomHeap(
    graph: [[(node: Int, weight: Int)]],
    source: Int,
    vertexCount: Int
) -> [Int] {
    var dist = [Int](repeating: Int.max, count: vertexCount)
    dist[source] = 0

    var heap = MinHeap()
    heap.insert((0, source))

    while let (currentDist, currentNode) = heap.popMin() {
        if currentDist > dist[currentNode] { continue }

        for (neighbor, weight) in graph[currentNode] {
            let newDist = currentDist + weight
            if newDist < dist[neighbor] {
                dist[neighbor] = newDist
                heap.insert((newDist, neighbor))
            }
        }
    }

    return dist
}

// MARK: - Build Weighted Graph Helper

func buildWeightedGraph(
    vertexCount: Int,
    edges: [(u: Int, v: Int, w: Int)],
    directed: Bool = false
) -> [[(node: Int, weight: Int)]] {
    var graph = [[(node: Int, weight: Int)]](repeating: [], count: vertexCount)
    for (u, v, w) in edges {
        graph[u].append((v, w))
        if !directed {
            graph[v].append((u, w))
        }
    }
    return graph
}

// MARK: - Example Usage

func dijkstraExample() {
    // Weighted undirected graph:
    //   0 --(4)-- 1 --(8)-- 2
    //   |         |         |
    //  (8)       (11)      (7)
    //   |         |         |
    //   7 --(1)-- 8 --(2)-- 6
    let edges: [(u: Int, v: Int, w: Int)] = [
        (0, 1, 4), (0, 7, 8),
        (1, 2, 8), (1, 7, 11),
        (2, 3, 7), (2, 8, 2),
        (3, 4, 9), (3, 5, 14),
        (4, 5, 10), (5, 6, 2),
        (6, 7, 1), (6, 8, 6),
        (7, 8, 7), (2, 5, 4)
    ]
    let graph = buildWeightedGraph(vertexCount: 9, edges: edges)

    let distances = dijkstraCustomHeap(graph: graph, source: 0, vertexCount: 9)
    print("Shortest distances from 0:", distances)
    // Output: [0, 4, 12, 19, 21, 11, 9, 8, 14]
}
