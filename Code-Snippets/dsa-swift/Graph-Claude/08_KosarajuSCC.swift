import Collections

// MARK: - Kosaraju's Algorithm (Strongly Connected Components)
//
// ============================================================================
// INTUITION:
// A Strongly Connected Component (SCC) is a maximal subset of vertices in a
// DIRECTED graph where every vertex is reachable from every other vertex in
// that subset.
//
// Kosaraju's uses TWO DFS passes:
//
// Pass 1: DFS on original graph → record nodes by FINISH TIME (like toposort).
//   Nodes that finish later are "earlier" in the dependency chain.
//
// Pass 2: REVERSE all edges, then DFS in reverse finish-time order.
//   Why reverse? In the original graph, SCC A might reach SCC B but not vice versa.
//   Reversing edges ensures that when we start DFS from the "earliest" SCC,
//   we can only reach nodes within the same SCC (the reversed inter-SCC edges
//   now point the wrong way). Each DFS call discovers exactly one SCC.
//
// Why it works:
// - Sorting by finish time ensures we process "source" SCCs first
// - Reversing edges prevents leaking into other SCCs during the second DFS
// - Each connected tree in the second DFS = one SCC
//
// USE CASES:
// 1. Finding strongly connected components in directed graphs
// 2. Simplifying/condensing a directed graph into a DAG of SCCs
// 3. 2-SAT problem solving
// 4. Analyzing web page link structure
// 5. Social network analysis (mutual friendship groups)
//
// USAGE PATTERNS:
// - Step 1: DFS → fill stack with finish order
// - Step 2: Transpose (reverse) the graph
// - Step 3: DFS on transposed graph in stack order → each DFS = one SCC
//
// TIME COMPLEXITY: O(V + E)
//   - DFS pass 1: O(V + E)
//   - Transposing graph: O(V + E)
//   - DFS pass 2: O(V + E)
//   - Total: O(3(V + E)) ~ O(V + E)
//
// SPACE COMPLEXITY: O(V + E)
//   - Visited array: O(V)
//   - Stack (finish order): O(V)
//   - Transposed graph: O(V + E)
// ============================================================================

/// Finds all Strongly Connected Components using Kosaraju's algorithm.
/// - Parameters:
///   - graph: Directed adjacency list
///   - vertexCount: Number of vertices
/// - Returns: Array of SCCs, where each SCC is an array of vertex indices
func kosarajuSCC(graph: [[Int]], vertexCount: Int) -> [[Int]] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var finishOrder = [Int]()    // Stack: nodes ordered by finish time

    // ── Step 1: DFS on original graph ──
    // Record nodes in order of their finish time.
    // This is NOT topological sort (graph may have cycles), but the ordering
    // ensures we process "source" SCCs first in Step 3.
    func dfsPass1(_ node: Int) {
        visited[node] = true
        for neighbor in graph[node] {
            if !visited[neighbor] {
                dfsPass1(neighbor)
            }
        }
        finishOrder.append(node)   // Push AFTER all neighbors are explored
    }

    for node in 0..<vertexCount {
        if !visited[node] {
            dfsPass1(node)
        }
    }

    // ── Step 2: Transpose (reverse) the graph ──
    // Reverse all edges: if u → v in original, then v → u in transposed.
    // This isolates SCCs — inter-SCC edges now point "backwards".
    var transposed = [[Int]](repeating: [], count: vertexCount)
    for u in 0..<vertexCount {
        for v in graph[u] {
            transposed[v].append(u)
        }
    }

    // ── Step 3: DFS on transposed graph in reverse finish order ──
    // Process nodes from highest to lowest finish time.
    // Each DFS call discovers exactly one SCC.
    visited = [Bool](repeating: false, count: vertexCount)
    var allSCCs = [[Int]]()

    func dfsPass2(_ node: Int, scc: inout [Int]) {
        visited[node] = true
        scc.append(node)
        for neighbor in transposed[node] {
            if !visited[neighbor] {
                dfsPass2(neighbor, scc: &scc)
            }
        }
    }

    // Process in reverse finish order (pop from stack)
    for node in finishOrder.reversed() {
        if !visited[node] {
            var scc = [Int]()
            dfsPass2(node, scc: &scc)
            allSCCs.append(scc)
        }
    }

    return allSCCs
}

/// Returns just the count of SCCs.
func countSCCs(graph: [[Int]], vertexCount: Int) -> Int {
    return kosarajuSCC(graph: graph, vertexCount: vertexCount).count
}

// MARK: - Example Usage

func kosarajuExample() {
    // Directed graph with 3 SCCs:
    //   SCC1: {0, 1, 2}  — 0→1→2→0
    //   SCC2: {3}         — 2→3
    //   SCC3: {4}         — 3→4
    //
    //   0 → 1
    //   ↑   ↓
    //   2 ← ┘
    //   ↓
    //   3 → 4
    var graph = [[Int]](repeating: [], count: 5)
    graph[0].append(1)
    graph[1].append(2)
    graph[2].append(0)   // Cycle: 0→1→2→0
    graph[2].append(3)
    graph[3].append(4)

    let sccs = kosarajuSCC(graph: graph, vertexCount: 5)
    print("Number of SCCs:", sccs.count)   // 3
    for (i, scc) in sccs.enumerated() {
        print("SCC \(i + 1):", scc)
    }
    // Possible output:
    // SCC 1: [0, 2, 1]
    // SCC 2: [3]
    // SCC 3: [4]
}
