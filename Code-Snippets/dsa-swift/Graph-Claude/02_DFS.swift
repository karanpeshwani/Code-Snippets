import Collections

// MARK: - Depth First Search (DFS)
//
// ============================================================================
// INTUITION:
// DFS explores a graph by going as DEEP as possible along each branch before
// backtracking. It uses a stack (explicit or recursion call stack).
// Think of it like exploring a maze — you go down one path until you hit a
// dead end, then backtrack and try the next unexplored path.
//
// USE CASES:
// 1. Cycle detection in graphs
// 2. Topological sorting (scheduling tasks with dependencies)
// 3. Finding connected components / strongly connected components
// 4. Pathfinding (does a path exist from A to B?)
// 5. Solving puzzles with one solution (mazes, Sudoku)
// 6. Tree traversals (preorder, inorder, postorder)
// 7. Detecting bridges and articulation points
//
// USAGE PATTERNS:
// - When you need to explore ALL paths or check existence → DFS
// - When the graph is deep and solutions are far from source → DFS is memory-efficient
// - When you need to process nodes in reverse finishing order → DFS (topological sort)
// - Backtracking problems → DFS
//
// TIME COMPLEXITY: O(V + E)
//   - Undirected graph: O(V + 2E) ~ O(V + E), each edge visited from both endpoints
//   - Directed graph: O(V + E), each edge visited once
//   - Each vertex visited exactly once via the visited check
//
// SPACE COMPLEXITY: O(V)
//   - Recursion stack: O(V) in worst case (linear chain graph)
//   - Visited array: O(V)
//   - Adjacency list: O(V + E) — input storage, not extra
// ============================================================================

// MARK: - Recursive DFS

/// DFS traversal using recursion.
/// - Parameters:
///   - graph: Adjacency list
///   - source: Starting node
///   - vertexCount: Total number of vertices
/// - Returns: Array of nodes in DFS traversal order
func dfs(graph: [[Int]], source: Int, vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var result = [Int]()

    func dfsHelper(_ node: Int) {
        visited[node] = true
        result.append(node)        // Process node (pre-order)

        for neighbor in graph[node] {
            if !visited[neighbor] {
                dfsHelper(neighbor)  // Go deeper before exploring siblings
            }
        }
    }

    dfsHelper(source)
    return result
}

// MARK: - Iterative DFS (using explicit stack)
//
// Useful when recursion depth could cause stack overflow (very deep graphs).
// NOTE: Iterative DFS processes neighbors in reverse order compared to recursive,
// unless you push neighbors in reverse order onto the stack.

/// DFS traversal using an explicit stack (no recursion).
func dfsIterative(graph: [[Int]], source: Int, vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var result = [Int]()
    var stack = [Int]()   // Array used as stack (append/removeLast)

    stack.append(source)

    while !stack.isEmpty {
        let current = stack.removeLast()

        if visited[current] { continue }
        visited[current] = true
        result.append(current)

        // Push neighbors in reverse to maintain left-to-right order
        for neighbor in graph[current].reversed() {
            if !visited[neighbor] {
                stack.append(neighbor)
            }
        }
    }

    return result
}

// MARK: - DFS for Disconnected Graphs

/// Handles disconnected graphs by trying DFS from every unvisited node.
func dfsDisconnected(graph: [[Int]], vertexCount: Int) -> [Int] {
    var visited = [Bool](repeating: false, count: vertexCount)
    var result = [Int]()

    func dfsHelper(_ node: Int) {
        visited[node] = true
        result.append(node)
        for neighbor in graph[node] {
            if !visited[neighbor] {
                dfsHelper(neighbor)
            }
        }
    }

    for node in 0..<vertexCount {
        if !visited[node] {
            dfsHelper(node)   // Start DFS for new component
        }
    }

    return result
}

// MARK: - DFS Path Finding

/// Checks if a path exists from source to destination using DFS.
func hasPath(graph: [[Int]], source: Int, destination: Int, vertexCount: Int) -> Bool {
    var visited = [Bool](repeating: false, count: vertexCount)

    func dfsHelper(_ node: Int) -> Bool {
        if node == destination { return true }
        visited[node] = true

        for neighbor in graph[node] {
            if !visited[neighbor] {
                if dfsHelper(neighbor) { return true }
            }
        }
        return false
    }

    return dfsHelper(source)
}

// MARK: - Example Usage

func dfsExample() {
    // Graph:
    //   0 -- 1 -- 3
    //   |    |
    //   2    4
    let edges = [(0, 1), (0, 2), (1, 3), (1, 4)]
    var graph = [[Int]](repeating: [], count: 5)
    for (u, v) in edges {
        graph[u].append(v)
        graph[v].append(u)
    }

    let recursive = dfs(graph: graph, source: 0, vertexCount: 5)
    print("DFS (recursive) from 0:", recursive)
    // Output: [0, 1, 3, 4, 2]

    let iterative = dfsIterative(graph: graph, source: 0, vertexCount: 5)
    print("DFS (iterative) from 0:", iterative)

    let pathExists = hasPath(graph: graph, source: 0, destination: 4, vertexCount: 5)
    print("Path from 0 to 4 exists:", pathExists)
    // Output: true
}
