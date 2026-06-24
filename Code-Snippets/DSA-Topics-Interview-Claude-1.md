# DSA Topics & Techniques — FAANG Interview Prep
> From basic to advanced, organized by data structure / category.
> **TC = Time Complexity (optimised LeetCode solution) | SC = Space Complexity**

---

## 1. Array

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Traversal, prefix sums, suffix sums | O(n) | O(n) |
| Basic | Frequency counting | O(n) | O(k) — k unique values |
| Basic | Kadane's Algorithm (Maximum Subarray) | O(n) | O(1) |
| Basic | Dutch National Flag (3-way partition) | O(n) | O(1) |
| Intermediate | Two Pointers (opposite ends) | O(n) | O(1) |
| Intermediate | Sliding Window (fixed & variable size) | O(n) | O(1)–O(k) |
| Intermediate | In-place rotation (reversal method) | O(n) | O(1) |
| Intermediate | Merge Intervals | O(n log n) | O(n) |
| Intermediate | Meeting Rooms / Interval Scheduling | O(n log n) | O(n) |
| Intermediate | Product of Array Except Self | O(n) | O(1) excl. output |
| Intermediate | Majority Element (Boyer-Moore Voting) | O(n) | O(1) |
| Advanced | Trapping Rain Water (two pointers) | O(n) | O(1) |
| Advanced | Next Permutation | O(n) | O(1) |
| Advanced | Jump Game (greedy variants) | O(n) | O(1) |
| Advanced | Median of Two Sorted Arrays (binary search) | O(log(min(m,n))) | O(1) |
| Advanced | Sparse Table / RMQ | O(n log n) build · O(1) query | O(n log n) |
| Advanced | Difference Array for range updates | O(1) update · O(n) reconstruct | O(n) |

> **Note — Sparse Table:** Immutable array only; supports O(1) range-min/max queries after O(n log n) preprocessing using overlapping windows of size 2^k.

---

## 2. String

| Level | Technique / Topic                                 | TC | SC |
|-------|---------------------------------------------------|----|----|
| Basic | Character frequency map                           | O(n) | O(k) — alphabet size |
| Basic | Palindrome check (two pointers)                   | O(n) | O(1) |
| Basic | Anagram detection                                 | O(n) | O(k) |
| Intermediate | Sliding window (longest substring without repeat) | O(n) | O(k) |
| Intermediate | Two pointers for string compression               | O(n) | O(1) |
| Intermediate | Rabin-Karp Rolling Hash                           | O(n+m) avg · O(nm) worst | O(1) |
| Intermediate | Z-Algorithm (pattern matching)                    | O(n+m) | O(n+m) |
| Intermediate | KMP Failure Function                              | O(n+m) | O(m) |
| Advanced | Aho-Corasick (multi-pattern matching)             | O(n + Σ\|pi\| + matches) | O(Σ\|pi\| · α) |
| Advanced | Suffix Array + LCP Array                          | O(n log n) | O(n) |
| Advanced | Suffix Automaton                                  | O(n) | O(n) |
| Advanced | Manacher's Algorithm (longest palindromic substring)                           | O(n) | O(n) |
| Advanced | Minimum Window Substring                          | O(n) | O(k) |
| Advanced | Word Break / Word Ladder (DP + BFS)               | O(n · m · 26) | O(n · m) |

> **Note — KMP vs Z:** KMP uses a failure function (prefix-suffix match array) to skip re-comparisons; Z-algorithm fills a Z-array where Z[i] = length of longest substring starting at i that matches a prefix. Both are O(n+m) but Z is simpler to implement.

---

## 3. Hash Table / Dictionary

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Frequency map, grouping anagrams | O(n log n) sort-key variant | O(n) |
| Basic | Two-sum with complement lookup | O(n) | O(n) |
| Intermediate | Prefix sum + hash map (subarray sum = k) | O(n) | O(n) |
| Intermediate | LRU Cache (HashMap + Doubly Linked List) | O(1) get/put | O(capacity) |
| Intermediate | LFU Cache (HashMap + frequency buckets) | O(1) get/put | O(capacity) |
| Intermediate | Counting subarrays with constraints | O(n) | O(n) |
| Advanced | Consistent Hashing | O(log n) lookup | O(n) |
| Advanced | Rolling hash for substring search | O(n+m) avg | O(1) |
| Advanced | Custom hashable types | O(1) amortized | O(n) |

> **Note — LRU Cache:** Achieved by combining a `HashMap<key, node>` with a doubly linked list. The list maintains recency order; the map gives O(1) access to any node for O(1) delete + re-insert.

---

## 4. Math & Number Theory

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | GCD / LCM (Euclidean Algorithm) | O(log min(a,b)) | O(1) |
| Basic | Sieve of Eratosthenes | O(n log log n) | O(n) |
| Basic | Fast power (exponentiation by squaring) | O(log n) | O(1) iterative |
| Intermediate | Modular inverse (Fermat's little theorem) | O(log mod) | O(1) |
| Intermediate | Pigeonhole principle | — proof technique | — |
| Intermediate | Counting / Combinatorics nCr mod p | O(n) precompute | O(n) |
| Intermediate | Pascal's Triangle | O(n²) | O(n) rolling row |
| Advanced | Chinese Remainder Theorem | O(log n) per pair | O(1) |
| Advanced | Matrix exponentiation (Fibonacci in O(log n)) | O(k³ log n) — k=matrix dim | O(k²) |
| Advanced | Catalan Numbers | O(n) | O(n) |
| Advanced | Digit DP | O(digits · states) | O(digits · states) |

---

## 5. Binary Search

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Classic binary search on sorted array | O(log n) | O(1) |
| Basic | Lower bound / Upper bound | O(log n) | O(1) |
| Intermediate | Binary search on answer space | O(log(range) · check) | O(1) |
| Intermediate | Rotated sorted array search | O(log n) | O(1) |
| Intermediate | Find peak element | O(log n) | O(1) |
| Intermediate | Search in 2D matrix | O(log(m·n)) | O(1) |
| Advanced | Binary search on floating point (precision) | O(log(1/ε)) | O(1) |
| Advanced | Parallel binary search | O(k · log n · check) | O(k) |
| Advanced | Fractional cascading | O(log n) query | O(n) preprocess |
| Advanced | Ternary search (unimodal functions) | O(log n) | O(1) |

> **Note — Binary Search on Answer:** Instead of searching an array, you binary search the valid *result range* (e.g., "minimum max distance") and check feasibility with a linear scan. Pattern: `lo=min_possible`, `hi=max_possible`, validate with O(n) check.

---

## 6. Sorting

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Bubble / Selection / Insertion Sort | O(n²) | O(1) |
| Basic | Merge Sort | O(n log n) | O(n) |
| Basic | Quick Sort (avg) | O(n log n) avg · O(n²) worst | O(log n) stack |
| Basic | Counting / Radix / Bucket Sort | O(n+k) / O(nk) / O(n+k) | O(n+k) |
| Intermediate | Heap Sort | O(n log n) | O(1) in-place |
| Intermediate | Tim Sort | O(n log n) | O(n) |
| Intermediate | Sort + Sweep (interval problems) | O(n log n) | O(n) |
| Advanced | External Sort | O(n log n) | O(B) buffer |
| Advanced | Wiggle Sort / custom comparator | O(n) or O(n log n) | O(1) |
| Advanced | QuickSelect — k-th smallest | O(n) avg · O(n²) worst | O(1) iterative |

---

## 7. Bit Manipulation

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | AND / OR / XOR / NOT / shifts | O(1) | O(1) |
| Basic | Check / set / clear / toggle a bit | O(1) | O(1) |
| Basic | Power of 2 check (`n & (n-1) == 0`) | O(1) | O(1) |
| Basic | Count set bits (Brian Kernighan) | O(k) — k set bits | O(1) |
| Intermediate | XOR tricks (single number, missing number) | O(n) | O(1) |
| Intermediate | Bitmask for subset enumeration | O(2ⁿ) | O(1) |
| Intermediate | Bitmask DP (TSP, assignment problems) | O(2ⁿ · n) | O(2ⁿ · n) |
| Advanced | Gosper's Hack (next bitmask with same popcount) | O(1) per next mask | O(1) |
| Advanced | SOS DP (Sum over Subsets) | O(2ⁿ · n) | O(2ⁿ) |
| Advanced | Bit-parallel operations | O(n/w) — w=word size | O(n/w) |

---

## 8. Linked List

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Traversal, insertion, deletion | O(n) / O(1) | O(1) |
| Basic | Reverse (iterative) | O(n) | O(1) |
| Intermediate | Fast & slow pointers — Floyd's cycle detection | O(n) | O(1) |
| Intermediate | Find middle node | O(n) | O(1) |
| Intermediate | Merge two sorted lists | O(n+m) | O(1) iterative |
| Intermediate | Find cycle start (Floyd's phase 2) | O(n) | O(1) |
| Intermediate | Reorder list / palindrome check | O(n) | O(1) |
| Advanced | Flatten multilevel doubly linked list | O(n) | O(d) — d=depth |
| Advanced | Copy list with random pointer | O(n) interleaving trick | O(1) |
| Advanced | LRU / LFU Cache | O(1) get/put | O(capacity) |
| Advanced | Skip List | O(log n) avg | O(n log n) |

---

## 9. Doubly Linked List

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Insertion / deletion from both ends | O(1) | O(1) |
| Intermediate | Deque implementation | O(1) push/pop | O(n) |
| Intermediate | LRU Cache (O(1) get/put) | O(1) | O(capacity) |
| Advanced | XOR Linked List | O(n) traversal | O(1) extra per node |

---

## 10. Stack

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Balanced parentheses | O(n) | O(n) |
| Basic | Evaluate RPN expressions | O(n) | O(n) |
| Intermediate | Monotonic Stack (next greater / smaller element) | O(n) | O(n) |
| Intermediate | Daily Temperatures / Stock Span | O(n) | O(n) |
| Intermediate | Largest Rectangle in Histogram | O(n) | O(n) |
| Intermediate | Trapping Rain Water (stack approach) | O(n) | O(n) |
| Advanced | Min Stack / Max Stack in O(1) | O(1) push/pop/min | O(n) |
| Advanced | Iterative DFS using explicit stack | O(V+E) | O(V) |
| Advanced | Remove k digits / lexicographically smallest | O(n) | O(n) |

> **Note — Monotonic Stack:** Each element is pushed and popped at most once → amortized O(1) per element → O(n) total. Key insight: when you pop, you've found the "next greater/smaller" for the popped element.

---

## 11. Queue / Deque

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | BFS traversal | O(V+E) | O(V) |
| Basic | Circular Queue implementation | O(1) enqueue/dequeue | O(n) |
| Intermediate | Double-Ended Queue (Deque) | O(1) push/pop | O(n) |
| Intermediate | Monotonic Deque (sliding window maximum) | O(n) total | O(k) window size |
| Advanced | Monotonic Deque for DP optimization | O(n) | O(n) |
| Advanced | 0-1 BFS (deque for edge weights 0 or 1) | O(V+E) | O(V) |

---

## 12. Heap / Priority Queue

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Min-heap / Max-heap insert/extract | O(log n) | O(n) |
| Basic | Heap Sort | O(n log n) | O(1) in-place |
| Intermediate | K largest / K smallest elements | O(n log k) | O(k) |
| Intermediate | Merge K sorted lists | O(n log k) | O(k) |
| Intermediate | Top K frequent elements | O(n log k) | O(n) |
| Intermediate | Median from data stream (two heaps) | O(log n) add · O(1) median | O(n) |
| Advanced | Dijkstra's SSSP with min-heap | O((V+E) log V) | O(V) |
| Advanced | Prim's MST with min-heap | O((V+E) log V) | O(V) |
| Advanced | Task Scheduler (greedy + heap) | O(n log k) | O(k) |
| Advanced | Lazy deletion heap | O(log n) amortized | O(n) |
| Advanced | Fibonacci Heap (theoretical) | O(1) amortized decrease-key | O(n) |

> **Note — Two Heaps for Median:** Maintain a max-heap of the lower half and a min-heap of the upper half, balanced ±1. Median is always the top of one or average of both tops.

---

## 13. Binary Tree

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Inorder / Preorder / Postorder (recursive & iterative) | O(n) | O(h) — h=height |
| Basic | Level-order traversal (BFS) | O(n) | O(w) — max width |
| Basic | Height, diameter, mirror/invert | O(n) | O(h) |
| Intermediate | LCA — recursive | O(n) | O(h) |
| Intermediate | Path sum variants | O(n) | O(h) |
| Intermediate | Serialize / Deserialize binary tree | O(n) | O(n) |
| Intermediate | Morris Traversal (O(1) space inorder) | O(n) | O(1) |
| Advanced | Binary Lifting for LCA | O(n log n) preprocess · O(log n) query | O(n log n) |
| Advanced | Euler Tour + Sparse Table for LCA | O(n log n) preprocess · O(1) query | O(n log n) |
| Advanced | Heavy-Light Decomposition (HLD) | O(n log n) build · O(log² n) path query | O(n) |
| Advanced | Centroid Decomposition | O(n log n) | O(n log n) |

> **Note — Morris Traversal:** Threads the tree by temporarily modifying right pointers to create a path back to the in-order successor — then restores them. Achieves true O(1) space without a stack.

---

## 14. Binary Search Tree (BST)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Insert / delete / search | O(log n) avg · O(n) worst | O(h) |
| Basic | In-order traversal gives sorted order | O(n) | O(h) |
| Intermediate | Validate BST | O(n) | O(h) |
| Intermediate | Kth smallest / largest | O(h + k) | O(h) |
| Intermediate | BST to sorted doubly linked list | O(n) | O(h) |
| Advanced | Balanced BST (AVL / Red-Black concepts) | O(log n) all ops | O(n) |
| Advanced | Order-statistics tree (rank / select) | O(log n) | O(n) |
| Advanced | Treap / Splay Tree | O(log n) expected | O(n) |

---

## 15. Trie (Prefix Tree)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Insert / search / startsWith | O(m) — m=word length | O(ALPHABET · n) |
| Intermediate | Word search in 2D grid (Trie + DFS) | O(m·n·4·L) — L=word len | O(total word chars) |
| Intermediate | Auto-complete system | O(p + results) | O(total chars) |
| Intermediate | Replace words with root (prefix matching) | O(n · m) | O(total dict chars) |
| Advanced | Bitwise Trie for XOR maximization | O(32 · n) | O(32 · n) |
| Advanced | Compressed Trie / Radix Tree | O(m) | O(n · m) compressed |
| Advanced | Aho-Corasick Automaton | O(n + Σ\|pi\| + matches) | O(Σ\|pi\| · α) |
| Advanced | Suffix Trie / Suffix Automaton | O(n) | O(n) |

---

## 16. Graph Theory

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Adjacency list / matrix | — | O(V+E) list · O(V²) matrix |
| Basic | BFS (shortest path unweighted) | O(V+E) | O(V) |
| Basic | DFS (components, cycle detection) | O(V+E) | O(V) |
| Basic | Bipartite check | O(V+E) | O(V) |
| Intermediate | Topological Sort — Kahn's (BFS, in-degree) | O(V+E) | O(V) |
| Intermediate | Topological Sort — DFS post-order | O(V+E) | O(V) |
| Intermediate | Detect cycle (directed & undirected) | O(V+E) | O(V) |
| Intermediate | Union-Find / DSU | O(α(n)) per op | O(n) |
| Intermediate | Kruskal's MST (DSU) | O(E log E) | O(V+E) |
| Intermediate | Prim's MST (heap) | O((V+E) log V) | O(V) |
| Intermediate | Dijkstra's SSSP | O((V+E) log V) | O(V) |
| Intermediate | 0-1 BFS | O(V+E) | O(V) |
| Advanced | Bellman-Ford (negative weights) | O(V · E) | O(V) |
| Advanced | Floyd-Warshall (all-pairs) | O(V³) | O(V²) |
| Advanced | Johnson's Algorithm | O(VE + V² log V) | O(V²) |
| Advanced | SCC — Kosaraju's | O(V+E) | O(V) |
| Advanced | SCC — Tarjan's | O(V+E) | O(V) |
| Advanced | Bridges & Articulation Points (Tarjan) | O(V+E) | O(V) |
| Advanced | Euler Path / Circuit (Hierholzer's) | O(V+E) | O(V+E) |
| Advanced | Hamiltonian Path (bitmask DP) | O(2ⁿ · n²) | O(2ⁿ · n) |
| Advanced | Max Flow — Ford-Fulkerson / Edmonds-Karp | O(V · E²) | O(V+E) |
| Advanced | Max Flow — Dinic's | O(V² · E) | O(V+E) |
| Advanced | Bipartite Matching — Hopcroft-Karp | O(E · √V) | O(V+E) |
| Advanced | A* Search | O(E log V) best case | O(V) |

> **Note — Bellman-Ford negative cycle detection:** Run V−1 relaxations; if any edge still relaxes on the V-th pass, a negative cycle exists. Used where Dijkstra fails (negative edges).

---

## 17. Dynamic Programming (DP)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Fibonacci (memoization / tabulation) | O(n) | O(n) or O(1) |
| Basic | Climbing Stairs / Coin Change | O(n·k) | O(n) or O(amount) |
| Basic | 0/1 Knapsack | O(n·W) | O(W) space-optimized |
| Basic | Longest Common Subsequence (LCS) | O(m·n) | O(min(m,n)) rolling |
| Basic | Longest Increasing Subsequence (LIS) — O(n²) | O(n²) | O(n) |
| Intermediate | Edit Distance (Levenshtein) | O(m·n) | O(min(m,n)) |
| Intermediate | Matrix Chain Multiplication | O(n³) | O(n²) |
| Intermediate | DP on Intervals (burst balloons) | O(n³) | O(n²) |
| Intermediate | DP on Trees (rerooting) | O(n) | O(n) |
| Intermediate | LIS in O(n log n) (patience sorting) | O(n log n) | O(n) |
| Intermediate | Unbounded / Bounded Knapsack | O(n·W) | O(W) |
| Intermediate | Partition DP (word break) | O(n²) or O(n · m) | O(n) |
| Intermediate | Digit DP | O(digits · states) | O(digits · states) |
| Advanced | Bitmask DP (TSP) | O(2ⁿ · n) | O(2ⁿ · n) |
| Advanced | DP + Monotonic Deque optimization | O(n) | O(n) |
| Advanced | Divide & Conquer DP optimization | O(n log n) | O(n) |
| Advanced | Convex Hull Trick / Li Chao Tree | O(n log n) | O(n) |
| Advanced | Knuth's Optimization (DP O(n³) → O(n²)) | O(n²) | O(n²) |
| Advanced | Profile DP (plug DP) | O(2^m · m · n) | O(2^m) |
| Advanced | DP on DAG | O(V+E) | O(V) |
| Advanced | Probability / Expected value DP | O(n · states) | O(n · states) |
| Advanced | Aliens Trick / WQS Binary Search | O(n log n) | O(n) |

> **Note — LIS O(n log n):** Maintain a `tails[]` array where `tails[i]` = smallest tail of all increasing subsequences of length i+1. Binary search for the correct position on each element. `tails` is always sorted.

> **Note — Convex Hull Trick:** Optimizes DP transitions of the form `dp[i] = min(dp[j] + b[j]*a[i])` — maintains a convex hull of lines, querying via sorted slopes or a pointer.

---

## 18. Recursion & Backtracking

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Generate all subsets (power set) | O(2ⁿ) | O(n) stack |
| Basic | Generate all permutations | O(n!) | O(n) stack |
| Basic | Generate all combinations | O(C(n,k)) | O(k) |
| Intermediate | N-Queens | O(n!) with pruning | O(n) |
| Intermediate | Sudoku Solver | O(9^81) worst, effective pruning | O(81) ≈ O(1) |
| Intermediate | Word Search (2D grid DFS) | O(m·n·4^L) | O(L) |
| Intermediate | Palindrome partitioning | O(n · 2ⁿ) | O(n) |
| Intermediate | Pruning with constraints | domain-dependent | O(depth) |
| Advanced | Branch & Bound | exponential, fast in practice | O(depth) |
| Advanced | Dancing Links (Knuth's Algorithm X) | O(cols · 2ⁿ) worst | O(rows · cols) |
| Advanced | Meet in the Middle | O(2^(n/2) · n) | O(2^(n/2)) |

---

## 19. Depth-First Search (DFS)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Tree / Graph DFS (recursive) | O(V+E) | O(h) tree · O(V) graph |
| Basic | Connected components | O(V+E) | O(V) |
| Intermediate | Number of Islands (flood fill) | O(m·n) | O(m·n) |
| Intermediate | Cycle detection — DFS colors (white/gray/black) | O(V+E) | O(V) |
| Intermediate | Topological sort (DFS post-order) | O(V+E) | O(V) |
| Intermediate | Iterative DFS (explicit stack) | O(V+E) | O(V) |
| Advanced | Tarjan's SCC & bridges | O(V+E) | O(V) |
| Advanced | Centroid / HLD decomposition | O(n log n) | O(n) |
| Advanced | Retrograde analysis | O(V+E) | O(V) |

---

## 20. Breadth-First Search (BFS)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Level-order tree traversal | O(n) | O(w) — max width |
| Basic | Shortest path (unweighted) | O(V+E) | O(V) |
| Intermediate | Multi-source BFS (0/1 matrix, rotting oranges) | O(m·n) | O(m·n) |
| Intermediate | BFS on implicit graphs (word ladder) | O(n · m · 26) | O(n · m) |
| Intermediate | Bidirectional BFS | O(b^(d/2)) — b=branch factor | O(b^(d/2)) |
| Advanced | 0-1 BFS with deque | O(V+E) | O(V) |
| Advanced | BFS on state-space (puzzle / game) | O(states · transitions) | O(states) |
| Advanced | Dial's Algorithm (bucket queue) | O(V + E + W) | O(V + W) |

> **Note — Bidirectional BFS:** Searches from both source and target simultaneously; meets in the middle. Reduces branching-factor exponent from d to d/2 — massive speedup for large graphs.

---

## 21. Greedy Algorithms

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Activity selection / interval scheduling | O(n log n) | O(n) |
| Basic | Fractional Knapsack | O(n log n) | O(1) |
| Basic | Huffman Encoding | O(n log n) | O(n) |
| Intermediate | Jump Game | O(n) | O(1) |
| Intermediate | Gas Station | O(n) | O(1) |
| Intermediate | Meeting rooms / min platforms | O(n log n) | O(n) |
| Intermediate | Task Scheduler | O(n) | O(1) — 26 task types |
| Advanced | Exchange argument proofs | — proof technique | — |
| Advanced | Greedy on graphs (Prim, Kruskal, Dijkstra) | O((V+E) log V) | O(V) |
| Advanced | Regret-based greedy | problem-specific | problem-specific |

---

## 22. Divide & Conquer

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Merge Sort / Quick Sort | O(n log n) | O(n) / O(log n) |
| Intermediate | Count inversions (merge sort variant) | O(n log n) | O(n) |
| Intermediate | Closest pair of points | O(n log n) | O(n) |
| Intermediate | Karatsuba multiplication | O(n^1.585) | O(n) |
| Advanced | FFT / NTT | O(n log n) | O(n) |
| Advanced | Divide & Conquer DP optimization | O(n log n) | O(n) |
| Advanced | Parallel binary search | O(k · log n · check) | O(k + n) |

---

## 23. Monotonic Stack / Queue

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Next Greater Element (NGE) | O(n) | O(n) |
| Intermediate | Previous Smaller Element | O(n) | O(n) |
| Intermediate | Largest Rectangle in Histogram | O(n) | O(n) |
| Intermediate | Sliding Window Maximum (monotonic deque) | O(n) | O(k) |
| Advanced | Sum of subarray minimums / maximums | O(n) | O(n) |
| Advanced | Remove Duplicate Letters (lex smallest) | O(n) | O(n) |
| Advanced | Monotonic Deque DP optimization | O(n) | O(n) |
| Advanced | Monotonic Double-Ended Queue for SMAWK / DP | O(n) | O(n) |

---

## 24. Segment Tree / Fenwick Tree (BIT)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Fenwick Tree (BIT) — point update, prefix query | O(log n) | O(n) |
| Intermediate | Segment Tree — range sum / min / max | O(log n) | O(n) |
| Intermediate | Lazy propagation on Segment Tree | O(log n) | O(n) |
| Advanced | Persistent Segment Tree | O(log n) per version | O(n log n) |
| Advanced | Merge Sort Tree (offline range queries) | O(n log n) build · O(log² n) query | O(n log n) |
| Advanced | Wavelet Tree | O(n log n) build · O(log n) query | O(n log n) |
| Advanced | Segment Tree Beats (Ji Driver) | O(n log² n) amortized | O(n) |
| Advanced | 2D Fenwick Tree | O(log² n) | O(n²) |
| Advanced | Dynamic Segment Tree | O(log n) | O(n log n) |

> **Note — Fenwick Tree vs Segment Tree:** BIT is simpler and uses less memory (O(n) vs O(4n)) but only supports prefix queries and point updates natively. Segment Tree with lazy propagation handles arbitrary range updates + queries.

---

## 25. Union-Find (Disjoint Set Union)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Union by rank / size | O(log n) | O(n) |
| Intermediate | Path compression | O(α(n)) amortized | O(n) |
| Intermediate | Cycle detection in undirected graph | O(α(n)) per op | O(n) |
| Intermediate | Kruskal's MST | O(E log E) | O(V) |
| Advanced | Weighted / bipartite DSU | O(α(n)) | O(n) |
| Advanced | Offline LCA with DSU (Tarjan's offline LCA) | O(n · α(n)) | O(n) |
| Advanced | Rollback DSU | O(log n) per op | O(n) |

> **Note — α(n):** Inverse Ackermann function, effectively O(1) for all practical inputs (n < 10^600). DSU with both union-by-rank and path compression achieves this bound.

---

## 26. Topological Sort

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Kahn's Algorithm (BFS, in-degree) | O(V+E) | O(V) |
| Intermediate | DFS post-order topological sort | O(V+E) | O(V) |
| Intermediate | Course Schedule (cycle detection) | O(V+E) | O(V) |
| Intermediate | Task ordering with dependencies | O(V+E) | O(V) |
| Advanced | Lexicographically smallest topological order | O((V+E) log V) — min-heap | O(V) |
| Advanced | Parallel task scheduling (critical path) | O(V+E) | O(V) |

---

## 27. Shortest Path Algorithms

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | BFS (unweighted) | O(V+E) | O(V) |
| Intermediate | Dijkstra (non-negative weights, min-heap) | O((V+E) log V) | O(V) |
| Intermediate | Bellman-Ford (negative weights) | O(V · E) | O(V) |
| Intermediate | 0-1 BFS (deque) | O(V+E) | O(V) |
| Advanced | Floyd-Warshall (all-pairs) | O(V³) | O(V²) |
| Advanced | Johnson's Algorithm (all-pairs sparse) | O(VE + V² log V) | O(V²) |
| Advanced | SPFA (Bellman-Ford + queue) | O(E) avg · O(VE) worst | O(V) |
| Advanced | A* (heuristic) | O(E log V) best case | O(V) |
| Advanced | Bidirectional Dijkstra | O((V+E) log V) halved | O(V) |

---

## 28. Minimum Spanning Tree (MST)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Kruskal's Algorithm (DSU, sort edges) | O(E log E) | O(V+E) |
| Intermediate | Prim's Algorithm (min-heap) | O((V+E) log V) | O(V) |
| Advanced | Borůvka's Algorithm | O(E log V) | O(V+E) |
| Advanced | Second Minimum Spanning Tree | O(E log E) | O(V+E) |
| Advanced | Maximum Spanning Tree (negate weights) | O(E log E) | O(V+E) |
| Advanced | Directed MST — Edmonds' (Chu-Liu) | O(V · E) | O(V+E) |

---

## 29. Network Flow

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Advanced | Ford-Fulkerson (DFS augmentation) | O(E · max_flow) | O(V+E) |
| Advanced | Edmonds-Karp (BFS augmentation) | O(V · E²) | O(V+E) |
| Advanced | Dinic's Algorithm | O(V² · E) | O(V+E) |
| Advanced | Push-Relabel | O(V² · √E) | O(V+E) |
| Advanced | Min-Cut / Max-Flow Theorem | same as flow algo | O(V+E) |
| Advanced | Bipartite Matching (as max flow) | O(E · √V) | O(V+E) |
| Advanced | Hopcroft-Karp | O(E · √V) | O(V+E) |
| Advanced | Min-Cost Max-Flow (MCMF) | O(VE² log V) | O(V+E) |
| Advanced | Circulation with lower bounds | O(V² · E) | O(V+E) |

---

## 30. Strongly Connected Components (SCC)

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Advanced | Kosaraju's Algorithm (two-pass DFS) | O(V+E) | O(V) |
| Advanced | Tarjan's Algorithm (low-link values) | O(V+E) | O(V) |
| Advanced | Condensation DAG (SCC → DAG) | O(V+E) | O(V+E) |
| Advanced | 2-SAT (SCC on implication graph) | O(V+E) | O(V) |

> **Note — Tarjan vs Kosaraju:** Both O(V+E). Tarjan does one DFS pass using a stack + low-link values. Kosaraju does two DFS passes (original graph, then reversed). Tarjan is preferred in competitive programming; Kosaraju is easier to understand.

---

## 31. Advanced Tree Structures

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Advanced | Heavy-Light Decomposition (HLD) | O(n log n) build · O(log² n) path query | O(n) |
| Advanced | Centroid Decomposition | O(n log n) | O(n log n) |
| Advanced | Link-Cut Tree | O(log n) amortized | O(n) |
| Advanced | Euler Tour Technique | O(n) build · O(1) subtree query | O(n) |
| Advanced | Small-to-Large Merging (DSU on tree) | O(n log n) | O(n) |
| Advanced | Virtual Tree | O(k log n) — k=query nodes | O(k) |
| Advanced | Auxiliary Tree | O(log n) | O(n) |

---

## 32. Geometry & Computational Geometry

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Convex Hull (Graham Scan / Jarvis March) | O(n log n) Graham · O(nh) Jarvis | O(n) |
| Intermediate | Line intersection, point in polygon | O(1) per pair · O(n) polygon | O(n) |
| Intermediate | Closest pair of points | O(n log n) | O(n) |
| Advanced | Rotating Calipers | O(n) on convex hull | O(1) |
| Advanced | Voronoi / Delaunay (concepts) | O(n log n) | O(n) |
| Advanced | Sweep Line Algorithm | O(n log n) | O(n) |
| Advanced | Half-plane intersection | O(n log n) | O(n) |

---

## 33. Sliding Window

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | Fixed-size sliding window (sum, max, avg) | O(n) | O(1) |
| Intermediate | Variable-size sliding window (longest substring) | O(n) | O(k) |
| Intermediate | Sliding window + frequency map | O(n) | O(k) |
| Advanced | Sliding window + monotonic deque (window max) | O(n) | O(k) |
| Advanced | Sliding window + two heaps (window median) | O(n log k) | O(k) |

---

## 34. Two Pointers

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | Two sum (sorted array) | O(n) | O(1) |
| Basic | Remove duplicates in-place | O(n) | O(1) |
| Intermediate | Three sum | O(n²) | O(1) excl. output |
| Intermediate | Four sum | O(n³) | O(1) excl. output |
| Intermediate | Container with most water | O(n) | O(1) |
| Intermediate | Partition array | O(n) | O(1) |
| Advanced | Two pointers on linked list (cycle, middle) | O(n) | O(1) |
| Advanced | Meet in the Middle | O(2^(n/2) · n) | O(2^(n/2)) |

---

## 35. Prefix Sum / Difference Array

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Basic | 1D prefix sum | O(n) build · O(1) query | O(n) |
| Intermediate | 2D prefix sum | O(m·n) build · O(1) query | O(m·n) |
| Intermediate | Difference array for range updates | O(1) update · O(n) reconstruct | O(n) |
| Intermediate | Prefix sum + hash map (subarray sum = k) | O(n) | O(n) |
| Advanced | Sparse table (RMQ) | O(n log n) build · O(1) query | O(n log n) |
| Advanced | Prefix XOR / prefix GCD | O(n) build · O(1) query | O(n) |

---

## 36. Randomized Algorithms

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Intermediate | QuickSelect (kth smallest) | O(n) avg · O(n²) worst | O(1) iterative |
| Intermediate | Randomized QuickSort | O(n log n) expected | O(log n) stack |
| Advanced | Monte Carlo / Las Vegas algorithms | problem-specific | problem-specific |
| Advanced | Bloom Filter | O(k) insert/query — k=hash fns | O(m) — m=bit array size |
| Advanced | Skip List | O(log n) avg | O(n log n) |
| Advanced | Reservoir Sampling | O(n) | O(k) — k=sample size |
| Advanced | Fisher-Yates Shuffle | O(n) | O(1) in-place |

> **Note — Bloom Filter:** Probabilistic set membership; never false negatives, small false positive rate. Uses k hash functions mapping to a bit array of size m. Cannot delete (use Counting Bloom Filter for that).

---

## 37. Miscellaneous Advanced Topics

| Level | Technique / Topic | TC | SC |
|-------|-------------------|----|----|
| Advanced | Mo's Algorithm (offline range queries) | O((n + q)·√n) | O(n) |
| Advanced | Square root decomposition | O(√n) per query | O(n) |
| Advanced | Block decomposition (√n blocks) | O(√n) update/query | O(n) |
| Advanced | Parallel binary search | O(k · log n · check) | O(k + n) |
| Advanced | CDQ Divide & Conquer (offline 3D partial order) | O(n log² n) | O(n) |
| Advanced | Fractional Cascading | O(log n) query | O(n) preprocess |
| Advanced | K-D Tree | O(log n) avg · O(√n) worst | O(n) |
| Advanced | van Emde Boas Tree | O(log log U) per op | O(U) |
| Advanced | Cache-oblivious algorithms | optimal cache misses | depends |

> **Note — Mo's Algorithm:** Offline range query algorithm. Sort queries by block of L in √n-sized blocks, then by R within each block. Pointer movement is amortized O((n+q)·√n). Requires queries to be answerable by adding/removing one element at a time.

---

## Quick Reference — LeetCode Pattern Map

```
Subarray sum / count         → Prefix Sum + Hash Map          O(n) / O(n)
Top K elements               → Heap (min/max)                 O(n log k) / O(k)
K-way merge                  → Heap                           O(n log k) / O(k)
Sliding window max/min       → Monotonic Deque                O(n) / O(k)
Next greater element         → Monotonic Stack                O(n) / O(n)
Shortest path (unweighted)   → BFS                            O(V+E) / O(V)
Shortest path (weighted)     → Dijkstra                       O((V+E)logV) / O(V)
Negative edge weights        → Bellman-Ford                   O(VE) / O(V)
All-pairs shortest path      → Floyd-Warshall                 O(V³) / O(V²)
Connected components         → DSU / DFS / BFS                O(α·n) / O(n)
Cycle detection (directed)   → DFS white/gray/black           O(V+E) / O(V)
Task ordering                → Topological Sort               O(V+E) / O(V)
Interval problems            → Sort + Greedy / Sweep Line     O(n log n) / O(n)
Subsets / Permutations       → Backtracking                   O(2ⁿ)/O(n!)
Optimal substructure         → DP                             varies
Overlapping subproblems      → Memoization                    varies
Prefix matching              → Trie                           O(m) / O(ALPHA·n)
XOR maximization             → Bitwise Trie                   O(32n) / O(32n)
Range update + range query   → Segment Tree (lazy)            O(log n) / O(n)
Point update + prefix query  → Fenwick Tree (BIT)             O(log n) / O(n)
MST                          → Kruskal (DSU) or Prim (heap)   O(E log E) / O(V)
SCC                          → Tarjan / Kosaraju              O(V+E) / O(V)
Max flow                     → Dinic's                        O(V²E) / O(V+E)
2-SAT                        → SCC on implication graph       O(V+E) / O(V)
```

---

*Last updated: June 2026*
