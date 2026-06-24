# DSA Topics & Techniques — FAANG Interview Prep
> From basic to advanced, organized by data structure / category.

---

## 1. Array

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Traversal, prefix sums, suffix sums |
| Basic | Frequency counting |
| Basic | Kadane's Algorithm (Maximum Subarray) |
| Basic | Dutch National Flag (3-way partition) |
| Intermediate | Two Pointers (opposite ends) |
| Intermediate | Sliding Window (fixed & variable size) |
| Intermediate | In-place rotation (reversal method) |
| Intermediate | Merge Intervals |
| Intermediate | Meeting Rooms / Interval Scheduling |
| Intermediate | Product of Array Except Self |
| Intermediate | Majority Element (Boyer-Moore Voting) |
| Advanced | Trapping Rain Water (two pointers / stack) |
| Advanced | Next Permutation |
| Advanced | Jump Game (greedy variants) |
| Advanced | Median of Two Sorted Arrays (binary search) |
| Advanced | Sparse Table / Range Minimum Query (RMQ) |
| Advanced | Difference Array for range updates |

---

## 2. String

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Character frequency map |
| Basic | Palindrome check (two pointers) |
| Basic | Anagram detection |
| Intermediate | Sliding window on string (longest substring without repeat) |
| Intermediate | Two pointers for string compression |
| Intermediate | Rabin-Karp Rolling Hash |
| Intermediate | Z-Algorithm (pattern matching) |
| Intermediate | KMP (Knuth-Morris-Pratt) Failure Function |
| Advanced | Aho-Corasick (multi-pattern matching) |
| Advanced | Suffix Array + LCP Array |
| Advanced | Suffix Automaton |
| Advanced | Manacher's Algorithm (longest palindromic substring O(n)) |
| Advanced | Minimum Window Substring |
| Advanced | Word Break / Word Ladder (DP + BFS) |

---

## 3. Hash Table / Dictionary

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Frequency map, grouping anagrams |
| Basic | Two-sum with complement lookup |
| Intermediate | Prefix sum + hash map (subarray sum = k) |
| Intermediate | LRU Cache (HashMap + Doubly Linked List) |
| Intermediate | LFU Cache (HashMap + frequency buckets) |
| Intermediate | Counting subarrays with constraints |
| Advanced | Consistent Hashing |
| Advanced | Rolling hash for substring search |
| Advanced | Custom hashable types |

---

## 4. Math & Number Theory

| Level | Technique / Topic |
|-------|-------------------|
| Basic | GCD / LCM (Euclidean Algorithm) |
| Basic | Prime checking, Sieve of Eratosthenes |
| Basic | Fast power (exponentiation by squaring) |
| Intermediate | Modular arithmetic, modular inverse |
| Intermediate | Pigeonhole principle |
| Intermediate | Counting / Combinatorics (nCr mod p) |
| Intermediate | Pascal's Triangle |
| Advanced | Chinese Remainder Theorem |
| Advanced | Matrix exponentiation (Fibonacci in O(log n)) |
| Advanced | Catalan Numbers |
| Advanced | Number of digits, digit DP |

---

## 5. Binary Search

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Classic binary search on sorted array |
| Basic | Lower bound / Upper bound |
| Intermediate | Binary search on answer space (search on result) |
| Intermediate | Rotated sorted array search |
| Intermediate | Find peak element |
| Intermediate | Search in 2D matrix |
| Advanced | Binary search on floating point (precision) |
| Advanced | Parallel binary search |
| Advanced | Fractional cascading |
| Advanced | Ternary search (unimodal functions) |

---

## 6. Sorting

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Bubble, Selection, Insertion Sort |
| Basic | Merge Sort (divide & conquer) |
| Basic | Quick Sort (Lomuto / Hoare partition) |
| Basic | Counting Sort, Radix Sort, Bucket Sort |
| Intermediate | Heap Sort |
| Intermediate | Tim Sort concepts |
| Intermediate | Sort + Sweep (interval problems) |
| Advanced | External Sort |
| Advanced | Wiggle Sort, custom comparator patterns |
| Advanced | Order statistics (k-th smallest via QuickSelect O(n) avg) |

---

## 7. Bit Manipulation

| Level | Technique / Topic |
|-------|-------------------|
| Basic | AND, OR, XOR, NOT, shifts |
| Basic | Check / set / clear / toggle a bit |
| Basic | Power of 2 check (`n & (n-1) == 0`) |
| Basic | Count set bits (Brian Kernighan) |
| Intermediate | XOR tricks (single number, missing number) |
| Intermediate | Bitmask for subset enumeration |
| Intermediate | DP with bitmask (TSP, assignment problems) |
| Advanced | Gosper's Hack (next permutation of bitmask) |
| Advanced | SOS DP (Sum over Subsets) |
| Advanced | Bit-parallel operations |

---

## 8. Linked List

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Traversal, insertion, deletion |
| Basic | Reverse a linked list (iterative & recursive) |
| Intermediate | Fast & slow pointers (Floyd's cycle detection) |
| Intermediate | Find middle node |
| Intermediate | Merge two sorted lists |
| Intermediate | Find cycle start (Floyd's phase 2) |
| Intermediate | Reorder list, palindrome check |
| Advanced | Flatten a multilevel doubly linked list |
| Advanced | Copy list with random pointer |
| Advanced | LRU / LFU Cache implementation |
| Advanced | Skip List |

---

## 9. Doubly Linked List

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Insertion / deletion from both ends |
| Intermediate | Deque implementation |
| Intermediate | LRU Cache (O(1) get/put) |
| Advanced | XOR Linked List (memory-efficient doubly linked list) |

---

## 10. Stack

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Balanced parentheses |
| Basic | Evaluate RPN expressions |
| Intermediate | Monotonic Stack (next greater / smaller element) |
| Intermediate | Daily Temperatures, Stock Span |
| Intermediate | Largest Rectangle in Histogram |
| Intermediate | Trapping Rain Water (stack approach) |
| Advanced | Min Stack / Max Stack in O(1) |
| Advanced | Iterative DFS using explicit stack |
| Advanced | Remove k digits / lexicographically smallest |

---

## 11. Queue / Deque

| Level | Technique / Topic |
|-------|-------------------|
| Basic | BFS traversal |
| Basic | Circular Queue implementation |
| Intermediate | Double-Ended Queue (Deque) |
| Intermediate | Monotonic Deque (sliding window maximum) |
| Advanced | Monotonic Double-Ended Queue (MDEDQ) for DP optimization |
| Advanced | 0-1 BFS (deque for edge weights 0 or 1) |

---

## 12. Heap / Priority Queue

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Min-heap, Max-heap operations |
| Basic | Heap Sort |
| Intermediate | K largest / K smallest elements |
| Intermediate | Merge K sorted lists |
| Intermediate | Top K frequent elements |
| Intermediate | Median from data stream (two heaps) |
| Advanced | Dijkstra's SSSP with min-heap |
| Advanced | Prim's MST with min-heap |
| Advanced | Task Scheduler (greedy + heap) |
| Advanced | Lazy deletion heap |
| Advanced | Fibonacci Heap (theoretical, amortized O(1) decrease-key) |

---

## 13. Binary Tree

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Inorder, Preorder, Postorder traversal (recursive & iterative) |
| Basic | Level-order traversal (BFS) |
| Basic | Height, diameter, mirror/invert |
| Intermediate | LCA (Lowest Common Ancestor) — recursive |
| Intermediate | Path sum variants |
| Intermediate | Serialize / Deserialize binary tree |
| Intermediate | Morris Traversal (O(1) space inorder) |
| Advanced | Binary Lifting for LCA (O(log n) per query) |
| Advanced | Euler Tour + Sparse Table for LCA |
| Advanced | Heavy-Light Decomposition (HLD) |
| Advanced | Centroid Decomposition |

---

## 14. Binary Search Tree (BST)

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Insert, delete, search |
| Basic | In-order gives sorted order |
| Intermediate | Validate BST |
| Intermediate | Kth smallest / largest in BST |
| Intermediate | BST to sorted doubly linked list |
| Advanced | Balanced BST (AVL, Red-Black Tree concepts) |
| Advanced | Order-statistics tree (rank / select) |
| Advanced | Treap, Splay Tree |

---

## 15. Trie (Prefix Tree)

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Insert / search / startsWith |
| Intermediate | Word search in 2D grid (Trie + DFS) |
| Intermediate | Auto-complete system |
| Intermediate | Replace words with root (prefix matching) |
| Advanced | Bitwise Trie for XOR maximization |
| Advanced | Compressed Trie / Radix Tree / Patricia Trie |
| Advanced | Aho-Corasick Automaton |
| Advanced | Suffix Trie / Suffix Automaton |

---

## 16. Graph Theory

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Adjacency list / matrix representation |
| Basic | BFS (shortest path in unweighted graph) |
| Basic | DFS (connected components, cycle detection) |
| Basic | Bipartite check |
| Intermediate | Topological Sort — Kahn's Algorithm (BFS, in-degree) |
| Intermediate | Topological Sort — DFS post-order |
| Intermediate | Detect cycle (directed & undirected) |
| Intermediate | Union-Find / Disjoint Set Union (DSU) |
| Intermediate | Minimum Spanning Tree — Kruskal's (DSU) |
| Intermediate | Minimum Spanning Tree — Prim's (heap) |
| Intermediate | Dijkstra's Algorithm (SSSP, non-negative weights) |
| Intermediate | 0-1 BFS |
| Advanced | Bellman-Ford Algorithm (negative weights, SSSP) |
| Advanced | Floyd-Warshall (all-pairs shortest path) |
| Advanced | Johnson's Algorithm (all-pairs, sparse graph) |
| Advanced | Strongly Connected Components — Kosaraju's |
| Advanced | Strongly Connected Components — Tarjan's |
| Advanced | Bridges & Articulation Points (Tarjan) |
| Advanced | Euler Path / Circuit (Hierholzer's Algorithm) |
| Advanced | Hamiltonian Path (bitmask DP) |
| Advanced | Max Flow — Ford-Fulkerson / Edmonds-Karp |
| Advanced | Max Flow — Dinic's Algorithm |
| Advanced | Min Cut — Max Flow theorem |
| Advanced | Bipartite Matching — Hungarian / Hopcroft-Karp |
| Advanced | A* Search (heuristic shortest path) |

---

## 17. Dynamic Programming (DP)

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Fibonacci (top-down memoization, bottom-up tabulation) |
| Basic | Climbing Stairs, Coin Change |
| Basic | 0/1 Knapsack |
| Basic | Longest Common Subsequence (LCS) |
| Basic | Longest Increasing Subsequence (LIS) — O(n²) |
| Intermediate | Edit Distance (Levenshtein) |
| Intermediate | Matrix Chain Multiplication |
| Intermediate | DP on Intervals (burst balloons, palindrome partition) |
| Intermediate | DP on Trees (rerooting technique) |
| Intermediate | LIS in O(n log n) (patience sorting / binary search) |
| Intermediate | Unbounded Knapsack, Bounded Knapsack |
| Intermediate | Partition DP (word break, palindrome partitioning) |
| Intermediate | Digit DP |
| Advanced | Bitmask DP (TSP, assignment, SOS) |
| Advanced | DP with Monotonic Deque optimization (1D/2D sliding window) |
| Advanced | Divide & Conquer DP optimization |
| Advanced | Convex Hull Trick (CHT) / Li Chao Tree |
| Advanced | Knuth's Optimization |
| Advanced | Profile DP (broken profile, plug DP) |
| Advanced | DP on DAG |
| Advanced | Probability / Expected value DP |
| Advanced | Aliens Trick (lambda optimization / WQS binary search) |

---

## 18. Recursion & Backtracking

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Generate all subsets (power set) |
| Basic | Generate all permutations |
| Basic | Generate all combinations |
| Intermediate | N-Queens problem |
| Intermediate | Sudoku Solver |
| Intermediate | Word Search (2D grid DFS) |
| Intermediate | Palindrome partitioning |
| Intermediate | Pruning with constraints |
| Advanced | Pruning with bounds (Branch & Bound) |
| Advanced | Dancing Links (Knuth's Algorithm X) |
| Advanced | Meet in the Middle (bidirectional search) |

---

## 19. Depth-First Search (DFS)

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Tree / Graph DFS (recursive) |
| Basic | Connected components |
| Intermediate | Number of Islands (DFS flood fill) |
| Intermediate | Cycle detection via DFS colors (white/gray/black) |
| Intermediate | Topological sort (DFS post-order) |
| Intermediate | Iterative DFS (explicit stack) |
| Advanced | Tarjan's SCC & bridges |
| Advanced | Centroid / HLD decomposition |
| Advanced | Retrograde analysis |

---

## 20. Breadth-First Search (BFS)

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Level-order tree traversal |
| Basic | Shortest path (unweighted) |
| Intermediate | Multi-source BFS (e.g., 0/1 matrix, rotting oranges) |
| Intermediate | BFS on implicit graphs (word ladder) |
| Intermediate | Bidirectional BFS |
| Advanced | 0-1 BFS with deque |
| Advanced | BFS on state-space (puzzle / game problems) |
| Advanced | Dial's Algorithm (bucket queue BFS) |

---

## 21. Greedy Algorithms

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Activity selection / interval scheduling |
| Basic | Fractional Knapsack |
| Basic | Huffman Encoding |
| Intermediate | Jump Game |
| Intermediate | Gas Station |
| Intermediate | Meeting rooms / min platforms |
| Intermediate | Task Scheduler |
| Advanced | Exchange argument proofs |
| Advanced | Greedy on graphs (Prim, Kruskal, Dijkstra) |
| Advanced | Regret-based greedy |

---

## 22. Divide & Conquer

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Merge Sort, Quick Sort |
| Intermediate | Count inversions (merge sort variant) |
| Intermediate | Closest pair of points |
| Intermediate | Karatsuba multiplication |
| Advanced | Fast Fourier Transform (FFT) / NTT |
| Advanced | Divide & Conquer DP optimization |
| Advanced | Parallel binary search |

---

## 23. Monotonic Stack / Queue

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Next Greater Element (NGE) |
| Intermediate | Previous Smaller Element |
| Intermediate | Largest Rectangle in Histogram |
| Intermediate | Sliding Window Maximum (monotonic deque) |
| Advanced | Sum of subarray minimums / maximums |
| Advanced | Remove Duplicate Letters (lexicographically smallest) |
| Advanced | Monotonic Deque DP optimization |
| Advanced | Monotonic Double-Ended Queue (MDEQ) for SMAWK / DP |

---

## 24. Segment Tree / Fenwick Tree (BIT)

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Fenwick Tree (BIT) — point update, prefix query |
| Intermediate | Segment Tree — range sum / min / max query |
| Intermediate | Lazy propagation on Segment Tree |
| Advanced | Persistent Segment Tree |
| Advanced | Merge Sort Tree (offline range queries) |
| Advanced | Wavelet Tree |
| Advanced | Segment Tree Beats (Ji Driver Segmentation) |
| Advanced | 2D Fenwick Tree |
| Advanced | Dynamic Segment Tree (coordinate compression) |

---

## 25. Union-Find (Disjoint Set Union)

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Union by rank / size |
| Intermediate | Path compression |
| Intermediate | Cycle detection in undirected graph |
| Intermediate | Kruskal's MST |
| Advanced | Weighted / bipartite DSU |
| Advanced | Offline LCA with DSU |
| Advanced | Rollback DSU (link-cut trees) |

---

## 26. Topological Sort

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Kahn's Algorithm (BFS, in-degree) |
| Intermediate | DFS post-order topological sort |
| Intermediate | Course Schedule (cycle detection) |
| Intermediate | Task ordering with dependencies |
| Advanced | Lexicographically smallest topological order |
| Advanced | Parallel task scheduling (critical path) |

---

## 27. Shortest Path Algorithms

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | BFS (unweighted) |
| Intermediate | Dijkstra (non-negative weights, min-heap) |
| Intermediate | Bellman-Ford (negative weights, SSSP, O(VE)) |
| Intermediate | 0-1 BFS (deque) |
| Advanced | Floyd-Warshall (all-pairs, O(V³)) |
| Advanced | Johnson's Algorithm (all-pairs sparse) |
| Advanced | SPFA (Bellman-Ford with queue, average O(E)) |
| Advanced | A* (heuristic, admissible/consistent) |
| Advanced | Bidirectional Dijkstra |

---

## 28. Minimum Spanning Tree (MST)

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Kruskal's Algorithm (DSU, sort edges) |
| Intermediate | Prim's Algorithm (min-heap) |
| Advanced | Borůvka's Algorithm |
| Advanced | Second Minimum Spanning Tree |
| Advanced | Maximum Spanning Tree (negate weights) |
| Advanced | Directed MST — Edmonds' Algorithm (Chu-Liu) |

---

## 29. Network Flow

| Level | Technique / Topic |
|-------|-------------------|
| Advanced | Ford-Fulkerson (DFS augmentation) |
| Advanced | Edmonds-Karp (BFS augmentation, O(VE²)) |
| Advanced | Dinic's Algorithm (O(V²E), BFS layering) |
| Advanced | Push-Relabel Algorithm |
| Advanced | Min-Cut / Max-Flow Theorem |
| Advanced | Bipartite Matching (as max flow) |
| Advanced | Hopcroft-Karp (O(√V · E) bipartite matching) |
| Advanced | Min-Cost Max-Flow (MCMF) |
| Advanced | Circulation with lower bounds |

---

## 30. Strongly Connected Components (SCC)

| Level | Technique / Topic |
|-------|-------------------|
| Advanced | Kosaraju's Algorithm (two-pass DFS) |
| Advanced | Tarjan's Algorithm (low-link values) |
| Advanced | Condensation DAG (SCC → DAG) |
| Advanced | 2-SAT (SCC on implication graph) |

---

## 31. Advanced Tree Structures

| Level | Technique / Topic |
|-------|-------------------|
| Advanced | Heavy-Light Decomposition (HLD) |
| Advanced | Centroid Decomposition |
| Advanced | Link-Cut Tree |
| Advanced | Euler Tour Technique |
| Advanced | Small-to-Large Merging (DSU on tree) |
| Advanced | Virtual Tree |
| Advanced | Auxiliary Tree |

---

## 32. Geometry & Computational Geometry

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Convex Hull (Graham Scan, Jarvis March) |
| Intermediate | Line intersection, point in polygon |
| Intermediate | Closest pair of points |
| Advanced | Rotating Calipers |
| Advanced | Voronoi Diagram / Delaunay Triangulation (concepts) |
| Advanced | Sweep Line Algorithm |
| Advanced | Half-plane intersection |

---

## 33. Sliding Window

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | Fixed-size sliding window (sum, max, average) |
| Intermediate | Variable-size sliding window (longest substring) |
| Intermediate | Sliding window + frequency map |
| Advanced | Sliding window + monotonic deque (window maximum) |
| Advanced | Sliding window + two heaps (window median) |

---

## 34. Two Pointers

| Level | Technique / Topic |
|-------|-------------------|
| Basic | Two sum (sorted array) |
| Basic | Remove duplicates in-place |
| Intermediate | Three sum, Four sum |
| Intermediate | Container with most water |
| Intermediate | Partition array |
| Advanced | Two pointers on linked list (cycle, middle) |
| Advanced | Multi-pointer (meeting in the middle) |

---

## 35. Prefix Sum / Difference Array

| Level | Technique / Topic |
|-------|-------------------|
| Basic | 1D prefix sum |
| Intermediate | 2D prefix sum |
| Intermediate | Difference array for range updates (O(1)) |
| Intermediate | Prefix sum + hash map (subarray sum = k) |
| Advanced | Sparse table (O(n log n) build, O(1) RMQ) |
| Advanced | Prefix XOR, prefix GCD |

---

## 36. Randomized Algorithms

| Level | Technique / Topic |
|-------|-------------------|
| Intermediate | QuickSelect (kth smallest, expected O(n)) |
| Intermediate | Randomized QuickSort |
| Advanced | Monte Carlo / Las Vegas algorithms |
| Advanced | Bloom Filter |
| Advanced | Skip List |
| Advanced | Reservoir Sampling |
| Advanced | Fisher-Yates Shuffle |

---

## 37. Miscellaneous Advanced Topics

| Level | Technique / Topic |
|-------|-------------------|
| Advanced | Offline algorithms (Mo's Algorithm for range queries) |
| Advanced | Square root decomposition |
| Advanced | Block decomposition (sqrt of n blocks) |
| Advanced | Parallel binary search |
| Advanced | CDQ Divide & Conquer (offline 3D partial order) |
| Advanced | Fractional Cascading |
| Advanced | K-D Tree |
| Advanced | van Emde Boas Tree |
| Advanced | Cache-oblivious algorithms |

---

## Quick Reference — LeetCode Pattern Map

```
Subarray sum / count         → Prefix Sum + Hash Map
Top K elements               → Heap (min/max)
K-way merge                  → Heap
Sliding window max/min       → Monotonic Deque
Next greater element         → Monotonic Stack
Shortest path (unweighted)   → BFS
Shortest path (weighted)     → Dijkstra
Negative weights             → Bellman-Ford
All-pairs shortest path      → Floyd-Warshall
Connected components         → DSU / DFS / BFS
Cycle detection (directed)   → DFS (white/gray/black) or Topo sort
Task ordering                → Topological Sort
Interval problems            → Sort + Greedy / Sweep Line
Subsets / Permutations       → Backtracking
Optimal substructure         → DP
Overlapping subproblems      → Memoization
Prefix matching              → Trie
XOR / Bit tricks             → Bitmask / Bitwise Trie
Range update + range query   → Segment Tree (lazy)
Point update + prefix query  → Fenwick Tree (BIT)
MST                          → Kruskal (DSU) or Prim (heap)
SCC                          → Tarjan / Kosaraju
Max flow                     → Dinic's
2-SAT                        → SCC on implication graph
```

---

*Last updated: June 2026*
