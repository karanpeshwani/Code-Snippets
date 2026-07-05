// MARK: - Disjoint Set Union (Union-Find)
//
// ============================================================================
// INTUITION:
// Disjoint Set Union (DSU) tracks a collection of non-overlapping sets.
// It supports two operations efficiently:
//   1. FIND: Which set does element x belong to? (returns the "representative")
//   2. UNION: Merge the sets containing x and y into one set
//
// Think of it as managing groups/clubs:
//   - Find: "Who is the leader of x's group?"
//   - Union: "Merge the groups of x and y"
//
// Two key optimizations make it near O(1) per operation:
//
// (a) PATH COMPRESSION (in Find):
//     When finding the root/representative, make every node along the path
//     point directly to the root. This flattens the tree, so future finds
//     on these nodes are O(1).
//     Before: 1 → 2 → 3 → 4 (root)
//     After:  1 → 4, 2 → 4, 3 → 4  (all point to root)
//
// (b) UNION BY RANK / UNION BY SIZE (in Union):
//     When merging two sets, attach the smaller/shorter tree under the
//     larger/taller tree. This keeps the tree balanced.
//     - By Rank: Track tree height; attach shorter tree under taller
//     - By Size: Track component size; attach smaller under larger
//
// With both optimizations: amortized O(α(n)) per operation, where α is the
// inverse Ackermann function — practically constant (< 5 for any real input).
//
// USE CASES:
// 1. Kruskal's MST algorithm
// 2. Detecting cycles in undirected graphs
// 3. Connected components (dynamic — edges added over time)
// 4. Network connectivity queries
// 5. Accounts merge / equivalence classes
// 6. LeetCode problems: redundant connection, number of provinces, etc.
//
// USAGE PATTERNS:
// - Initialize: each element is its own set (parent[i] = i)
// - Union(x, y): merge sets of x and y
// - Find(x): get representative of x's set
// - Connected(x, y): check if x and y are in the same set (find(x) == find(y))
//
// TIME COMPLEXITY: O(α(n)) amortized per operation
//   - α(n) is the inverse Ackermann function, practically ≤ 4 for n ≤ 10^80
//   - Without optimizations: O(n) per operation in worst case
//   - With only path compression: O(log n) amortized
//   - With both path compression + union by rank/size: O(α(n)) ≈ O(1)
//
// SPACE COMPLEXITY: O(n)
//   - Parent array: O(n)
//   - Rank or size array: O(n)
// ============================================================================

// MARK: - Union by Rank

/// Disjoint Set Union with path compression and union by rank.
///
/// Rank represents an upper bound on the height of the tree.
/// Attach shorter tree under taller tree to keep trees balanced.
class DSUByRank {
    private var parent: [Int]
    private var rank: [Int]

    /// Initialize DSU with n elements (0-indexed).
    /// Each element starts as its own set (self-loop: parent[i] = i).
    init(_ n: Int) {
        parent = Array(0..<n)       // parent[i] = i → each is its own root
        rank = [Int](repeating: 0, count: n)   // All trees have height 0
    }

    /// Find the representative (root) of the set containing x.
    ///
    /// PATH COMPRESSION: Recursively find root, then point x directly to root.
    /// All nodes along the path are flattened to point directly to root.
    /// This makes subsequent finds O(1) for these nodes.
    func find(_ x: Int) -> Int {
        if parent[x] != x {
            parent[x] = find(parent[x])   // Path compression — direct link to root
        }
        return parent[x]
    }

    /// Union the sets containing x and y.
    ///
    /// UNION BY RANK: Attach the tree with smaller rank under the tree with larger rank.
    /// If ranks are equal, arbitrarily choose one as root and increment its rank.
    ///
    /// - Returns: true if x and y were in different sets (union performed),
    ///            false if already in the same set
    @discardableResult
    func union(_ x: Int, _ y: Int) -> Bool {
        let rootX = find(x)
        let rootY = find(y)

        if rootX == rootY { return false }   // Already in the same set

        // Attach smaller rank tree under larger rank tree
        if rank[rootX] < rank[rootY] {
            parent[rootX] = rootY
        } else if rank[rootX] > rank[rootY] {
            parent[rootY] = rootX
        } else {
            // Same rank — pick one as root, increment its rank
            parent[rootY] = rootX
            rank[rootX] += 1
        }

        return true
    }

    /// Check if x and y are in the same set.
    func connected(_ x: Int, _ y: Int) -> Bool {
        return find(x) == find(y)
    }
}

// MARK: - Union by Size

/// Disjoint Set Union with path compression and union by size.
///
/// Instead of rank (height), we track the SIZE of each component.
/// This is often more useful because we can query component sizes.
///
/// NOTE: After path compression, rank becomes unreliable (tree is flattened
/// but rank isn't updated). Size remains accurate because it counts elements,
/// not structure. This is why Union by Size is often preferred.
class DSUBySize {
    private var parent: [Int]
    private(set) var size: [Int]    // size[i] = number of elements in i's component

    init(_ n: Int) {
        parent = Array(0..<n)
        size = [Int](repeating: 1, count: n)   // Each component starts with size 1
    }

    /// Find root with path compression.
    func find(_ x: Int) -> Int {
        if parent[x] != x {
            parent[x] = find(parent[x])
        }
        return parent[x]
    }

    /// Union by size: attach smaller component under larger component.
    /// This keeps the tree balanced, minimizing height.
    @discardableResult
    func union(_ x: Int, _ y: Int) -> Bool {
        let rootX = find(x)
        let rootY = find(y)

        if rootX == rootY { return false }

        // Attach smaller tree under larger tree
        if size[rootX] < size[rootY] {
            parent[rootX] = rootY
            size[rootY] += size[rootX]   // Absorb x's component size
        } else {
            parent[rootY] = rootX
            size[rootX] += size[rootY]
        }

        return true
    }

    func connected(_ x: Int, _ y: Int) -> Bool {
        return find(x) == find(y)
    }

    /// Returns the size of the component containing x.
    func componentSize(_ x: Int) -> Int {
        return size[find(x)]
    }

    /// Returns the number of distinct components.
    func componentCount() -> Int {
        var roots = Set<Int>()
        for i in 0..<parent.count {
            roots.insert(find(i))
        }
        return roots.count
    }
}

// MARK: - Example Usage

func dsuExample() {
    // Union by Rank
    let dsuRank = DSUByRank(7)
    dsuRank.union(0, 1)
    dsuRank.union(1, 2)
    dsuRank.union(3, 4)
    dsuRank.union(5, 6)
    dsuRank.union(4, 5)

    print("Rank - 0 and 2 connected:", dsuRank.connected(0, 2))   // true
    print("Rank - 0 and 5 connected:", dsuRank.connected(0, 5))   // false
    print("Rank - 3 and 6 connected:", dsuRank.connected(3, 6))   // true

    // Union by Size
    let dsuSize = DSUBySize(7)
    dsuSize.union(0, 1)
    dsuSize.union(1, 2)
    dsuSize.union(3, 4)
    dsuSize.union(5, 6)
    dsuSize.union(4, 5)

    print("Size - Component of 0:", dsuSize.componentSize(0))     // 3
    print("Size - Component of 3:", dsuSize.componentSize(3))     // 4
    print("Size - Total components:", dsuSize.componentCount())    // 2
}
