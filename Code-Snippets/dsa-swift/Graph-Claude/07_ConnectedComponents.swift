import Collections

// MARK: - Number of Connected Components
//
// ============================================================================
// INTUITION:
// A connected component is a maximal set of vertices such that every pair is
// connected by a path. To count components, we iterate over all vertices:
// each time we find an unvisited vertex, we start a new BFS/DFS to mark all
// vertices in its component as visited, and increment the count.
//
// For GRID-based problems (e.g., Number of Islands), the same idea applies —
// each cell is a "vertex" and adjacent cells (up/down/left/right) are "edges".
//
// USE CASES:
// 1. Number of Islands (LeetCode 200)
// 2. Connected components in social networks (friend groups)
// 3. Counting clusters in data
// 4. Flood fill algorithm
// 5. Image segmentation
//
// USAGE PATTERNS:
// - Graph: Iterate nodes 0..V-1, BFS/DFS from each unvisited node
// - Grid: Iterate all cells, BFS/DFS from each unvisited '1' cell
// - Can also use Union-Find (Disjoint Set) for this
//
// TIME COMPLEXITY:
//   Graph: O(V + E) — standard traversal
//   Grid:  O(N * M) — visit each cell once, N = rows, M = cols
//
// SPACE COMPLEXITY:
//   Graph: O(V) — visited array + queue/stack
//   Grid:  O(N * M) — visited array; queue/stack at most O(N * M)
// ============================================================================

// MARK: - Graph: Connected Components using BFS

/// Counts the number of connected components in an undirected graph using BFS.
func countComponentsBFS(graph: [[Int]], vertexCount: Int) -> Int {
    var visited = [Bool](repeating: false, count: vertexCount)
    var componentCount = 0
    var queue = Deque<Int>()

    for node in 0..<vertexCount {
        if !visited[node] {
            componentCount += 1       // Found a new component

            // BFS to mark all nodes in this component
            visited[node] = true
            queue.append(node)
            while let current = queue.popFirst() {
                for neighbor in graph[current] {
                    if !visited[neighbor] {
                        visited[neighbor] = true
                        queue.append(neighbor)
                    }
                }
            }
        }
    }

    return componentCount
}

// MARK: - Graph: Connected Components using DFS

/// Counts the number of connected components in an undirected graph using DFS.
func countComponentsDFS(graph: [[Int]], vertexCount: Int) -> Int {
    var visited = [Bool](repeating: false, count: vertexCount)
    var componentCount = 0

    func dfs(_ node: Int) {
        visited[node] = true
        for neighbor in graph[node] {
            if !visited[neighbor] {
                dfs(neighbor)
            }
        }
    }

    for node in 0..<vertexCount {
        if !visited[node] {
            componentCount += 1
            dfs(node)
        }
    }

    return componentCount
}

// MARK: - Grid: Number of Islands (BFS)

/// Counts the number of islands (connected components of '1's) in a grid.
/// Uses BFS to flood-fill each island. 4-directional connectivity.
///
/// This is the classic "Number of Islands" problem (LeetCode 200).
func numberOfIslandsBFS(_ grid: [[Character]]) -> Int {
    guard !grid.isEmpty else { return 0 }

    let rows = grid.count
    let cols = grid[0].count
    var visited = [[Bool]](repeating: [Bool](repeating: false, count: cols), count: rows)
    var islandCount = 0

    // 4 directions: up, down, left, right
    let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    for r in 0..<rows {
        for c in 0..<cols {
            if grid[r][c] == "1" && !visited[r][c] {
                islandCount += 1

                // BFS to mark entire island
                var queue = Deque<(Int, Int)>()
                visited[r][c] = true
                queue.append((r, c))

                while let (row, col) = queue.popFirst() {
                    for (dr, dc) in directions {
                        let newRow = row + dr
                        let newCol = col + dc
                        // Bounds check + land check + unvisited check
                        if newRow >= 0 && newRow < rows &&
                           newCol >= 0 && newCol < cols &&
                           grid[newRow][newCol] == "1" &&
                           !visited[newRow][newCol] {
                            visited[newRow][newCol] = true
                            queue.append((newRow, newCol))
                        }
                    }
                }
            }
        }
    }

    return islandCount
}

// MARK: - Grid: Number of Islands (DFS)

/// Counts islands using DFS flood-fill.
func numberOfIslandsDFS(_ grid: [[Character]]) -> Int {
    guard !grid.isEmpty else { return 0 }

    let rows = grid.count
    let cols = grid[0].count
    var visited = [[Bool]](repeating: [Bool](repeating: false, count: cols), count: rows)
    var islandCount = 0

    let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    func dfs(_ row: Int, _ col: Int) {
        visited[row][col] = true
        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc
            if newRow >= 0 && newRow < rows &&
               newCol >= 0 && newCol < cols &&
               grid[newRow][newCol] == "1" &&
               !visited[newRow][newCol] {
                dfs(newRow, newCol)
            }
        }
    }

    for r in 0..<rows {
        for c in 0..<cols {
            if grid[r][c] == "1" && !visited[r][c] {
                islandCount += 1
                dfs(r, c)
            }
        }
    }

    return islandCount
}

// MARK: - Example Usage

func connectedComponentsExample() {
    // Graph: 0-1, 2-3, 4 (3 components)
    var graph = [[Int]](repeating: [], count: 5)
    graph[0].append(1); graph[1].append(0)
    graph[2].append(3); graph[3].append(2)

    print("Components (BFS):", countComponentsBFS(graph: graph, vertexCount: 5))  // 3
    print("Components (DFS):", countComponentsDFS(graph: graph, vertexCount: 5))  // 3

    // Grid (Number of Islands):
    let grid: [[Character]] = [
        ["1", "1", "0", "0", "0"],
        ["1", "1", "0", "0", "0"],
        ["0", "0", "1", "0", "0"],
        ["0", "0", "0", "1", "1"]
    ]

    print("Islands (BFS):", numberOfIslandsBFS(grid))  // 3
    print("Islands (DFS):", numberOfIslandsDFS(grid))  // 3
}
