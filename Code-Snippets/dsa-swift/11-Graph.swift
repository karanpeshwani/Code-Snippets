//
//  11-Graph.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 06/06/26.
//

import Foundation

// MARK: - Representations

// ── Adjacency List (unweighted, undirected) ───────────────────────────────────
var adjList = [Int: [Int]]()
func addEdge(_ u: Int, _ v: Int, directed: Bool = false) {
    adjList[u, default: []].append(v)
    if !directed { adjList[v, default: []].append(u) }
}

// ── Adjacency List (weighted, directed) ──────────────────────────────────────
var weighted = [Int: [(node: Int, weight: Int)]]()
func addWeightedEdge(_ u: Int, _ v: Int, _ w: Int) {
    weighted[u, default: []].append((v, w))
}

// ── Adjacency Matrix (dense graphs) ──────────────────────────────────────────
// var matrix = Array(repeating: Array(repeating: 0, count: n), count: n)
// matrix[u][v] = 1   (or weight)

// ── Edge List ─────────────────────────────────────────────────────────────────
// var edges = [(u: Int, v: Int, w: Int)]()

// MARK: - DFS — Recursive   O(V + E)

func dfsRecursive(graph: [Int: [Int]], node: Int, visited: inout Set<Int>, result: inout [Int]) {
    visited.insert(node)
    result.append(node)
    for neighbor in graph[node, default: []] where !visited.contains(neighbor) {
        dfsRecursive(graph: graph, node: neighbor, visited: &visited, result: &result)
    }
}

// MARK: - DFS — Iterative   O(V + E)

func dfsIterative(graph: [Int: [Int]], start: Int) -> [Int] {
    var visited = Set<Int>(), result = [Int](), stack = [start]
    while !stack.isEmpty {
        let node = stack.removeLast()
        if visited.contains(node) { continue }
        visited.insert(node)
        result.append(node)
        for neighbor in graph[node, default: []].reversed() {
            if !visited.contains(neighbor) { stack.append(neighbor) }
        }
    }
    return result
}

// MARK: - BFS   O(V + E)

func bfsGraph(graph: [Int: [Int]], start: Int) -> [Int] {
    var visited = Set([start]), result = [Int](), queue = [start]
    while !queue.isEmpty {
        let node = queue.removeFirst()   // use Deque in practice
        result.append(node)
        for neighbor in graph[node, default: []] where !visited.contains(neighbor) {
            visited.insert(neighbor)
            queue.append(neighbor)
        }
    }
    return result
}

// MARK: - Topological Sort — Kahn's Algorithm (BFS)   O(V + E)

func topologicalSortKahn(graph: [Int: [Int]], numNodes: Int) -> [Int]? {
    var inDegree = Array(repeating: 0, count: numNodes)
    for (_, neighbors) in graph {
        for v in neighbors { inDegree[v] += 1 }
    }

    var queue = inDegree.indices.filter { inDegree[$0] == 0 }
    var result = [Int]()

    while !queue.isEmpty {
        let u = queue.removeFirst()
        result.append(u)
        for v in graph[u, default: []] {
            inDegree[v] -= 1
            if inDegree[v] == 0 { queue.append(v) }
        }
    }
    return result.count == numNodes ? result : nil   // nil = cycle detected
}

// MARK: - Topological Sort — DFS   O(V + E)

func topologicalSortDFS(graph: [Int: [Int]], numNodes: Int) -> [Int] {
    var visited = Set<Int>(), stack = [Int]()
    func dfs(_ node: Int) {
        visited.insert(node)
        for neighbor in graph[node, default: []] where !visited.contains(neighbor) {
            dfs(neighbor)
        }
        stack.append(node)
    }
    for node in 0..<numNodes where !visited.contains(node) { dfs(node) }
    return stack.reversed()
}

// MARK: - Cycle Detection — Undirected (DFS)   O(V + E)

func hasCycleUndirected(graph: [Int: [Int]], numNodes: Int) -> Bool {
    var visited = Set<Int>()
    func dfs(_ node: Int, _ parent: Int) -> Bool {
        visited.insert(node)
        for neighbor in graph[node, default: []] {
            if !visited.contains(neighbor) {
                if dfs(neighbor, node) { return true }
            } else if neighbor != parent { return true }
        }
        return false
    }
    for node in 0..<numNodes where !visited.contains(node) {
        if dfs(node, -1) { return true }
    }
    return false
}

// MARK: - Cycle Detection — Directed (DFS with color)   O(V + E)
// 0 = unvisited, 1 = in stack, 2 = done

func hasCycleDirected(graph: [Int: [Int]], numNodes: Int) -> Bool {
    var color = Array(repeating: 0, count: numNodes)
    func dfs(_ u: Int) -> Bool {
        color[u] = 1
        for v in graph[u, default: []] {
            if color[v] == 1 { return true }
            if color[v] == 0 && dfs(v) { return true }
        }
        color[u] = 2
        return false
    }
    for node in 0..<numNodes where color[node] == 0 {
        if dfs(node) { return true }
    }
    return false
}

// MARK: - Bipartite Check (2-colouring with BFS)   O(V + E)

func isBipartite(graph: [Int: [Int]], numNodes: Int) -> Bool {
    var color = Array(repeating: -1, count: numNodes)
    for start in 0..<numNodes where color[start] == -1 {
        var queue = [start]
        color[start] = 0
        while !queue.isEmpty {
            let u = queue.removeFirst()
            for v in graph[u, default: []] {
                if color[v] == -1 { color[v] = 1 - color[u]; queue.append(v) }
                else if color[v] == color[u] { return false }
            }
        }
    }
    return true
}

// MARK: - Connected Components   O(V + E)

func countComponents(graph: [Int: [Int]], numNodes: Int) -> Int {
    var visited = Set<Int>(), count = 0
    func dfs(_ node: Int) {
        visited.insert(node)
        for neighbor in graph[node, default: []] where !visited.contains(neighbor) { dfs(neighbor) }
    }
    for node in 0..<numNodes where !visited.contains(node) { dfs(node); count += 1 }
    return count
}

// MARK: - Number of Islands (Grid DFS)   O(m × n)

func numIslands(_ grid: inout [[Character]]) -> Int {
    let rows = grid.count, cols = grid[0].count
    var count = 0

    func dfs(_ r: Int, _ c: Int) {
        guard r >= 0, r < rows, c >= 0, c < cols, grid[r][c] == "1" else { return }
        grid[r][c] = "0"   // mark visited by sinking
        dfs(r+1, c); dfs(r-1, c); dfs(r, c+1); dfs(r, c-1)
    }

    for r in 0..<rows {
        for c in 0..<cols where grid[r][c] == "1" { dfs(r, c); count += 1 }
    }
    return count
}

// MARK: - Union-Find (Disjoint Set Union)   Nearly O(1) per operation

struct UnionFind {
    private var parent: [Int]
    private var rank:   [Int]
    private(set) var components: Int

    init(_ n: Int) {
        parent = Array(0..<n)
        rank   = Array(repeating: 0, count: n)
        components = n
    }

    mutating func find(_ x: Int) -> Int {
        if parent[x] != x { parent[x] = find(parent[x]) }   // path compression
        return parent[x]
    }

    mutating func union(_ x: Int, _ y: Int) -> Bool {
        let px = find(x), py = find(y)
        if px == py { return false }   // already connected
        // Union by rank
        if rank[px] < rank[py] { parent[px] = py }
        else if rank[px] > rank[py] { parent[py] = px }
        else { parent[py] = px; rank[px] += 1 }
        components -= 1
        return true
    }

    mutating func connected(_ x: Int, _ y: Int) -> Bool { find(x) == find(y) }
}

// MARK: - Dijkstra's Shortest Path   O((V + E) log V)

func dijkstras(graph: [Int: [(node: Int, weight: Int)]], start: Int, n: Int) -> [Int] {
    var dist = Array(repeating: Int.max, count: n)
    dist[start] = 0
    // Min-heap: (distance, node) — use BinaryHeap from 08-Heap.swift in practice
    var pq = [(d: Int, node: Int)]()
    pq.append((0, start))

    while !pq.isEmpty {
        pq.sort { $0.d < $1.d }            // replace with heap.popMin()
        let (d, u) = pq.removeFirst()
        if d > dist[u] { continue }        // stale entry
        for (v, w) in graph[u, default: []] {
            if dist[u] + w < dist[v] {
                dist[v] = dist[u] + w
                pq.append((dist[v], v))
            }
        }
    }
    return dist   // dist[i] = shortest distance from start to i  (Int.max = unreachable)
}

// MARK: - Bellman-Ford (handles negative weights)   O(V × E)

func bellmanFord(edges: [(u: Int, v: Int, w: Int)], start: Int, n: Int) -> [Int]? {
    var dist = Array(repeating: Int.max / 2, count: n)
    dist[start] = 0

    for _ in 0..<n - 1 {
        for (u, v, w) in edges where dist[u] != Int.max / 2 {
            if dist[u] + w < dist[v] { dist[v] = dist[u] + w }
        }
    }
    // Detect negative cycle
    for (u, v, w) in edges where dist[u] + w < dist[v] { return nil }
    return dist
}

// MARK: - Minimum Spanning Tree — Kruskal's   O(E log E)

func kruskalMST(n: Int, edges: [(u: Int, v: Int, w: Int)]) -> Int {
    let sorted = edges.sorted { $0.w < $1.w }
    var uf = UnionFind(n)
    var totalWeight = 0

    for (u, v, w) in sorted {
        if uf.union(u, v) { totalWeight += w }
    }
    return totalWeight
}

// MARK: - Clone Graph   O(V + E)

final class GNode {
    var val: Int
    var neighbors: [GNode]
    init(_ val: Int = 0) { self.val = val; self.neighbors = [] }
}

func cloneGraph(_ node: GNode?) -> GNode? {
    guard let node = node else { return nil }
    var cloned = [Int: GNode]()

    func dfs(_ n: GNode) -> GNode {
        if let existing = cloned[n.val] { return existing }
        let copy = GNode(n.val)
        cloned[n.val] = copy
        copy.neighbors = n.neighbors.map { dfs($0) }
        return copy
    }
    return dfs(node)
}

// MARK: - Course Schedule (LC 207) — Cycle in directed graph

func canFinish(_ numCourses: Int, _ prerequisites: [[Int]]) -> Bool {
    var graph = [Int: [Int]]()
    for p in prerequisites { graph[p[1], default: []].append(p[0]) }
    return !hasCycleDirected(graph: graph, numNodes: numCourses)
}
