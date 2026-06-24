# DSA Topics & Techniques — FAANG Interview Master List

> Organized by Data Structure · Basic → Advanced · LeetCode / FAANG Focus

---

## Table of Contents

1. [Array](#1-array)
2. [String](#2-string)
3. [Hash Table / Dictionary](#3-hash-table--dictionary)
4. [Math & Number Theory](#4-math--number-theory)
5. [Bit Manipulation](#5-bit-manipulation)
6. [Sorting & Searching](#6-sorting--searching)
7. [Binary Search](#7-binary-search)
8. [Linked List](#8-linked-list)
9. [Stack](#9-stack)
10. [Queue & Deque](#10-queue--deque)
11. [Heap / Priority Queue](#11-heap--priority-queue)
12. [Tree (Binary Tree & BST)](#12-tree-binary-tree--bst)
13. [Trie (Prefix Tree)](#13-trie-prefix-tree)
14. [Graph](#14-graph)
15. [Dynamic Programming](#15-dynamic-programming)
16. [Backtracking & Recursion](#16-backtracking--recursion)
17. [Greedy Algorithms](#17-greedy-algorithms)
18. [Divide & Conquer](#18-divide--conquer)
19. [Design & System Patterns](#19-design--system-patterns)

---

## 1. Array

### Basic
- [ ] Array traversal, insertion, deletion
- [ ] Prefix Sum
- [ ] Suffix Sum
- [ ] Running Product / Prefix Product
- [ ] Kadane's Algorithm (Maximum Subarray)

### Intermediate
- [ ] **Two Pointers** (opposite ends — sorted arrays, palindrome checks)
- [ ] **Fast & Slow Pointers** (Floyd's cycle detection applied to arrays)
- [ ] **Sliding Window** (fixed size)
- [ ] **Variable-Size Sliding Window** (dynamic constraint — longest, shortest)
- [ ] Dutch National Flag (3-way partition)
- [ ] Merge Intervals
- [ ] Interval Scheduling / Overlap detection
- [ ] Matrix traversal (row, column, diagonal, spiral)
- [ ] Rotate Matrix in-place
- [ ] Set Matrix Zeroes (in-place marking)

### Advanced
- [ ] Reservoir Sampling (random sampling from stream)
- [ ] Boyer-Moore Voting Algorithm (majority element)
- [ ] Trapping Rain Water (two-pointer & stack approaches)
- [ ] Jump Game (greedy + DP)
- [ ] Subarray Sum equals K (prefix sum + hash map)
- [ ] Next Permutation (lexicographic order)
- [ ] Counting Sort / Bucket Sort on arrays
- [ ] Cyclic Sort (find missing/duplicate in 1–N range)
- [ ] Sweep Line (overlapping intervals, meeting rooms)

---

## 2. String

### Basic
- [ ] String reversal, palindrome check
- [ ] Anagram check (sort or frequency map)
- [ ] Character frequency counting
- [ ] ASCII / character math

### Intermediate
- [ ] **Two Pointers on strings** (valid palindrome II)
- [ ] **Sliding Window on strings** (minimum window substring, longest without repeat)
- [ ] String encoding / decoding (run-length encoding)
- [ ] Valid Parentheses (stack-based)
- [ ] String-to-integer (atoi) — edge case handling
- [ ] Longest Common Prefix

### Advanced
- [ ] **KMP Algorithm** (Knuth-Morris-Pratt — pattern matching in O(n))
- [ ] **Rabin-Karp** (rolling hash for pattern matching)
- [ ] **Z-Algorithm** (linear string matching)
- [ ] **Manacher's Algorithm** (longest palindromic substring in O(n))
- [ ] Regular Expression Matching (DP)
- [ ] Wildcard Matching (DP)
- [ ] Word Break (DP + Trie)
- [ ] Palindrome Partitioning (DP + backtracking)

---

## 3. Hash Table / Dictionary

### Basic
- [ ] Frequency counting
- [ ] Two Sum pattern (complement lookup)
- [ ] Grouping / categorizing elements
- [ ] Caching repeated results

### Intermediate
- [ ] **HashMap + Two Pointers** (subarrays, substrings)
- [ ] Prefix Sum + HashMap (subarray sum == k)
- [ ] Anagram grouping (sorted key or tuple key)
- [ ] Isomorphic strings / word pattern
- [ ] Consistent hashing concepts

### Advanced
- [ ] **LRU Cache** (HashMap + Doubly Linked List)
- [ ] **LFU Cache** (HashMap + frequency buckets)
- [ ] Custom hash function design
- [ ] Rolling Hash (Rabin-Karp sliding window)
- [ ] Count Distinct with `k` constraint (sliding window + hash map)

---

## 4. Math & Number Theory

### Basic
- [ ] GCD / LCM (Euclidean algorithm)
- [ ] Prime check (trial division)
- [ ] Factorial, Fibonacci (iterative & memoized)
- [ ] Power of 2, 3, etc.

### Intermediate
- [ ] **Sieve of Eratosthenes** (all primes up to N)
- [ ] Modular arithmetic (mod, modular inverse)
- [ ] Fast Power / Exponentiation by Squaring
- [ ] Integer overflow guards (use Long / Int64)
- [ ] Pascal's Triangle
- [ ] Combinatorics (nCr, permutations)

### Advanced
- [ ] **Chinese Remainder Theorem**
- [ ] **Euler's Totient Function**
- [ ] Catalan Numbers (valid parentheses, BST count)
- [ ] Matrix Exponentiation (Fibonacci in O(log n))
- [ ] Reservoir Sampling
- [ ] Random Pick with Weight (prefix sum + binary search)
- [ ] Geometry — Convex Hull, Line intersection
- [ ] Game Theory — Nim, Sprague-Grundy theorem

---

## 5. Bit Manipulation

### Basic
- [ ] AND, OR, XOR, NOT, left shift, right shift
- [ ] Check / set / clear / toggle a bit
- [ ] Count set bits (Brian Kernighan's algorithm)
- [ ] Power of 2 check (`n & (n-1) == 0`)

### Intermediate
- [ ] XOR tricks (find single number, missing number)
- [ ] Bit masking for subsets
- [ ] Swap without temp variable
- [ ] Reverse bits
- [ ] Number of 1 bits (Hamming weight)

### Advanced
- [ ] **Bitmask DP** (TSP, subset enumeration)
- [ ] Counting bits in range (digit DP with bits)
- [ ] Maximum XOR of two numbers (Trie approach)
- [ ] Single Number III (two missing/extra — XOR partitioning)
- [ ] Gray Code generation

---

## 6. Sorting & Searching

### Basic
- [ ] Bubble, Selection, Insertion Sort (O(n²))
- [ ] Merge Sort (O(n log n), stable)
- [ ] Quick Sort (O(n log n) avg, in-place)
- [ ] Heap Sort

### Intermediate
- [ ] **Counting Sort** (O(n+k), integer keys)
- [ ] **Radix Sort** (O(nk), digit by digit)
- [ ] **Bucket Sort** (uniform distribution)
- [ ] **Custom Comparator / Comparisons** (sort by frequency, by length+lex)
- [ ] Partial Sort / QuickSelect (kth largest in O(n) avg)
- [ ] External Sort concepts

### Advanced
- [ ] **Tim Sort** (Python's built-in — hybrid merge+insertion)
- [ ] Patience Sorting (LIS connection)
- [ ] Order Statistics (rank queries)

---

## 7. Binary Search

### Basic
- [ ] Classic binary search on sorted array
- [ ] Find first / last occurrence
- [ ] Search in rotated sorted array

### Intermediate
- [ ] **Binary Search on Answer** (minimize max, maximize min)
- [ ] Search in 2D matrix
- [ ] Find peak element
- [ ] Square root / nth root (binary search on result space)
- [ ] Koko eating bananas pattern (search on rate/speed)

### Advanced
- [ ] Binary Search + Greedy (split array largest sum, capacity to ship packages)
- [ ] Binary Search on floating point
- [ ] **Fractional Cascading** (multi-level binary search)
- [ ] Binary Search in infinite/unbounded array
- [ ] Count of smaller numbers after self (merge sort or BIT)

---

## 8. Linked List

### Basic
- [ ] Traversal, insertion, deletion (head/tail/middle)
- [ ] Reverse a linked list (iterative & recursive)
- [ ] Find middle node (fast & slow pointers)

### Intermediate
- [ ] **Fast & Slow Pointers** (cycle detection — Floyd's algorithm)
- [ ] Merge two sorted lists
- [ ] Remove nth node from end
- [ ] Intersection of two linked lists
- [ ] Palindrome linked list

### Advanced
- [ ] **Doubly Linked List** (LRU Cache, browser history)
- [ ] Reverse nodes in k-groups
- [ ] Flatten a multilevel doubly linked list
- [ ] Copy list with random pointer (deep copy)
- [ ] Sort linked list (merge sort on list)
- [ ] Skip List (probabilistic data structure)

---

## 9. Stack

### Basic
- [ ] LIFO operations, call stack simulation
- [ ] Valid parentheses / bracket matching
- [ ] Implement queue using stacks

### Intermediate
- [ ] **Monotonic Stack** (next greater element, next smaller element)
- [ ] Daily Temperatures pattern
- [ ] Largest Rectangle in Histogram
- [ ] Trapping Rain Water (stack approach)
- [ ] Evaluate Reverse Polish Notation
- [ ] Min Stack (O(1) min with auxiliary stack)

### Advanced
- [ ] **Monotonic Decreasing Stack** (stock span, sum of subarray minimums)
- [ ] **Monotonic Increasing Stack** (largest rectangle variants)
- [ ] Asteroid Collision
- [ ] Remove k digits to make smallest number
- [ ] 132 Pattern detection

---

## 10. Queue & Deque

### Basic
- [ ] FIFO operations, BFS queue
- [ ] Implement stack using queues
- [ ] Circular Queue

### Intermediate
- [ ] **Monotonic Deque** (sliding window maximum/minimum)
- [ ] **Double-Ended Queue (Deque)** operations
- [ ] BFS level-order traversal
- [ ] Shortest path in unweighted graph (BFS)
- [ ] Rotting Oranges / multi-source BFS

### Advanced
- [ ] **Monotonic Double-Ended Queue** (sliding window max with constraints)
- [ ] Deque-based DP optimization (largest sum rectangle, max sum subarray with length constraint)
- [ ] Jump Game VI (DP + deque O(n))
- [ ] Priority Queue + BFS (0-1 BFS, Dijkstra)

---

## 11. Heap / Priority Queue

### Basic
- [ ] Min-Heap, Max-Heap operations (insert, extract, peek)
- [ ] Kth Largest / Kth Smallest element
- [ ] Sort using heap (Heap Sort)

### Intermediate
- [ ] **K-way merge** (merge k sorted lists/arrays)
- [ ] Top K frequent elements (heap + hash map)
- [ ] Find median from data stream (two heaps)
- [ ] Task Scheduler (greedy + max-heap)
- [ ] Reorganize String

### Advanced
- [ ] **Dijkstra's Algorithm** (min-heap + adjacency list, O((V+E) log V))
- [ ] **Prim's Algorithm** (MST via min-heap)
- [ ] **A\* Search** (heuristic-guided Dijkstra)
- [ ] Sliding Window Median (two heaps + lazy deletion)
- [ ] IPO / maximize capital (dual heap greedy)
- [ ] **Fibonacci Heap** (theoretical — Dijkstra O(E + V log V))

---

## 12. Tree (Binary Tree & BST)

### Basic
- [ ] Tree traversals — Inorder, Preorder, Postorder (recursive & iterative)
- [ ] Level-order traversal (BFS)
- [ ] Height / depth of tree
- [ ] Count nodes, leaf nodes
- [ ] Mirror / invert a binary tree

### Intermediate
- [ ] **DFS on trees** (path sum, diameter, LCA)
- [ ] Lowest Common Ancestor (LCA) — binary tree & BST
- [ ] Validate BST
- [ ] Construct tree from preorder + inorder
- [ ] Serialize and deserialize binary tree
- [ ] Path sum (root-to-leaf, any path)
- [ ] Diameter of binary tree
- [ ] Balanced binary tree check
- [ ] Binary Tree Maximum Path Sum

### Advanced
- [ ] **Morris Traversal** (O(1) space inorder)
- [ ] **Segment Tree** (range queries — sum, min, max with point/range updates)
- [ ] **Fenwick Tree / Binary Indexed Tree (BIT)** (prefix sums, range queries)
- [ ] **AVL Tree / Red-Black Tree** (self-balancing BST concepts)
- [ ] **Euler Tour + LCA with sparse table** (O(1) LCA queries)
- [ ] Heavy-Light Decomposition (path queries on trees)
- [ ] **Centroid Decomposition** (tree distance problems)
- [ ] **Treap** (randomized BST)
- [ ] Persistent Segment Tree (version queries)
- [ ] Order Statistics Tree (rank, select in O(log n))

---

## 13. Trie (Prefix Tree)

### Basic
- [ ] Insert, search, startsWith operations
- [ ] Word dictionary / auto-complete

### Intermediate
- [ ] **Word Search II** (Trie + DFS on board)
- [ ] Longest Word in Dictionary
- [ ] Replace Words (prefix replacement)
- [ ] Map Sum Pairs

### Advanced
- [ ] **Bitwise Trie** (Maximum XOR of two numbers)
- [ ] Trie + DP (Word Break II, concatenated words)
- [ ] Compact Trie / Patricia Trie (space optimization)
- [ ] Aho-Corasick Algorithm (multi-pattern string matching)
- [ ] Suffix Trie / Suffix Array (all substrings, pattern matching)

---

## 14. Graph

### Representations
- [ ] Adjacency Matrix vs Adjacency List vs Edge List
- [ ] Directed vs Undirected, Weighted vs Unweighted

### Basic Traversal
- [ ] **Depth-First Search (DFS)** — iterative & recursive
- [ ] **Breadth-First Search (BFS)** — shortest path, level traversal
- [ ] Connected components
- [ ] Flood Fill / Island counting (DFS/BFS on grid)

### Shortest Path
- [ ] **Dijkstra's Algorithm** (non-negative weights, min-heap, O((V+E) log V))
- [ ] **Bellman-Ford Algorithm** (negative weights, O(VE), detect negative cycles)
- [ ] **Floyd-Warshall** (all-pairs shortest path, O(V³))
- [ ] **0-1 BFS** (edges with weight 0 or 1, deque)
- [ ] **A\* Search** (heuristic shortest path)
- [ ] SPFA (Bellman-Ford with queue optimization)

### Minimum Spanning Tree
- [ ] **Kruskal's Algorithm** (sort edges + Union-Find, O(E log E))
- [ ] **Prim's Algorithm** (min-heap, O((V+E) log V))
- [ ] Borůvka's Algorithm

### Topological Sort
- [ ] **Kahn's Algorithm** (BFS-based, in-degree reduction)
- [ ] **DFS-based Topological Sort** (reverse postorder)
- [ ] Cycle detection in directed graph
- [ ] Course Schedule pattern

### Connectivity
- [ ] Union-Find / Disjoint Set Union (DSU)
  - [ ] Union by Rank
  - [ ] Path Compression
  - [ ] Weighted Union-Find
- [ ] **Tarjan's Algorithm** — Strongly Connected Components (SCC)
- [ ] **Kosaraju's Algorithm** — SCC (two-pass DFS)
- [ ] **Bridges & Articulation Points** (Tarjan's bridge finding)
- [ ] Bipartite Graph check (2-coloring BFS/DFS)
- [ ] **Eulerian Path / Circuit** (Hierholzer's algorithm)
- [ ] **Hamiltonian Path** (backtracking — NP-hard)

### Advanced Graph
- [ ] **Network Flow — Ford-Fulkerson** (augmenting paths, max flow)
- [ ] **Edmonds-Karp** (BFS-based max flow, O(VE²))
- [ ] **Dinic's Algorithm** (level graph, blocking flow, O(V²E))
- [ ] Min-Cut / Max-Flow theorem
- [ ] **Hungarian Algorithm** (bipartite matching, assignment problem)
- [ ] **Bellman-Ford SPFA variants**
- [ ] Johnson's Algorithm (reweighting for all-pairs)
- [ ] Centroid Decomposition on graphs
- [ ] Virtual Nodes / Super Source-Sink tricks

---

## 15. Dynamic Programming

### Patterns

#### 1D DP (Sequences)
- [ ] Fibonacci-style (climbing stairs, house robber)
- [ ] **Longest Increasing Subsequence (LIS)** — O(n²) & O(n log n) with patience sort
- [ ] Maximum Subarray (Kadane's)
- [ ] Coin Change (unbounded knapsack variant)
- [ ] Word Break
- [ ] Decode Ways

#### 2D DP (Grids & Strings)
- [ ] **Longest Common Subsequence (LCS)**
- [ ] **Edit Distance** (Levenshtein)
- [ ] **0/1 Knapsack**
- [ ] Unique Paths (grid DP)
- [ ] Minimum Path Sum
- [ ] Longest Common Substring
- [ ] Regular Expression / Wildcard Matching

#### Interval DP
- [ ] **Matrix Chain Multiplication**
- [ ] Burst Balloons
- [ ] Palindrome Partitioning II
- [ ] Stone Merge / Zuma Game

#### Tree DP
- [ ] House Robber III (trees)
- [ ] Binary Tree Camera
- [ ] Maximum Independent Set on Tree

#### Bitmask DP
- [ ] **Travelling Salesman Problem (TSP)**
- [ ] Minimum Cost to Visit Every Node
- [ ] Shortest Superstring

#### DP with Data Structures
- [ ] **DP + Monotonic Deque** (O(n) sliding window DP)
- [ ] **DP + Segment Tree / BIT** (O(n log n) LIS, count inversions)
- [ ] **DP + Divide and Conquer** (Knuth's optimization, O(n² → n log n))

#### Advanced DP
- [ ] **Digit DP** (count numbers with property in range [L, R])
- [ ] **DP on Broken Profile** (grid tiling)
- [ ] **SOS DP** (Sum over Subsets, O(n·2ⁿ))
- [ ] **Convex Hull Trick (CHT)** (line DP optimization, O(n log n) or O(n))
- [ ] **Aliens Trick / Lambda Optimization** (WQS binary search)
- [ ] **Li Chao Tree** (CHT with dynamic line insertion)

---

## 16. Backtracking & Recursion

### Basic
- [ ] Factorial, Fibonacci (recursive)
- [ ] Power set / all subsets
- [ ] All permutations
- [ ] All combinations

### Intermediate
- [ ] **Subsets with duplicates** (sort + skip)
- [ ] **Permutations with duplicates**
- [ ] **Combination Sum** (unbounded / bounded choices)
- [ ] N-Queens
- [ ] Sudoku Solver
- [ ] Word Search (DFS + backtrack on grid)
- [ ] Generate Parentheses

### Advanced
- [ ] **Pruning strategies** (early termination, feasibility checks)
- [ ] **Bitmask + backtracking** (state compression)
- [ ] Palindrome Partitioning
- [ ] Expression Add Operators
- [ ] Remove Invalid Parentheses (BFS backtrack)
- [ ] Cryptarithmetic solver

---

## 17. Greedy Algorithms

### Basic
- [ ] Activity Selection / Interval scheduling
- [ ] Fractional Knapsack
- [ ] Minimum number of coins (canonical coin systems)

### Intermediate
- [ ] **Interval Scheduling Maximization** (sort by end time)
- [ ] Meeting Rooms I & II
- [ ] Jump Game I & II
- [ ] Gas Station (circular route)
- [ ] Assign Cookies / Two-pointer greedy

### Advanced
- [ ] **Huffman Encoding** (optimal prefix codes)
- [ ] Task Scheduler (greedy + heap)
- [ ] IPO (maximize capital — dual heap)
- [ ] Greedy + Binary Search (Minimum # arrows to burst balloons)
- [ ] Monotone Queue greedy
- [ ] Exchange Argument proofs (proving greedy correctness)

---

## 18. Divide & Conquer

### Basic
- [ ] Merge Sort
- [ ] Quick Sort / QuickSelect
- [ ] Binary Search (recursive)

### Intermediate
- [ ] Count Inversions (merge sort variant)
- [ ] Closest Pair of Points
- [ ] Majority Element (D&C approach)
- [ ] Pow(x, n) — fast exponentiation

### Advanced
- [ ] **Karatsuba Multiplication** (fast integer multiply)
- [ ] FFT / NTT (Fast Fourier Transform — polynomial multiply)
- [ ] Strassen's Matrix Multiplication
- [ ] Skyline Problem (divide & conquer + merge)

---

## 19. Design & System Patterns

### Data Structure Design
- [ ] **LRU Cache** (O(1) get/put — HashMap + DLL)
- [ ] **LFU Cache** (O(1) all ops — HashMap + frequency map)
- [ ] **Min Stack** (O(1) min)
- [ ] **Max Stack** (O(1) max with lazy deletion)
- [ ] Implement Queue with Stacks / Stack with Queues
- [ ] **Median Finder** (two heaps)
- [ ] **Time-Based Key-Value Store** (HashMap + binary search)
- [ ] **Skip List** (O(log n) probabilistic)
- [ ] **Trie with autocomplete ranking**
- [ ] **Segment Tree with lazy propagation**

### Algorithmic Patterns Summary

| Pattern | Typical Use Case | Complexity |
|---|---|---|
| Two Pointers | Sorted array, palindrome | O(n) |
| Sliding Window | Subarray/substring constraint | O(n) |
| Fast & Slow Pointers | Cycle detection, middle of list | O(n) |
| Binary Search on Answer | Min/max optimization | O(n log n) |
| Monotonic Stack | Next greater/smaller | O(n) |
| Monotonic Deque | Sliding window max/min | O(n) |
| Prefix Sum | Range sum queries | O(1) query |
| Union-Find | Dynamic connectivity | O(α(n)) |
| BFS (shortest path) | Unweighted graphs | O(V+E) |
| Dijkstra | Weighted shortest path | O((V+E) log V) |
| Topological Sort | Dependency ordering | O(V+E) |
| Segment Tree | Range queries + updates | O(log n) |
| Bitmask DP | Subset enumeration | O(n·2ⁿ) |
| Digit DP | Count in range [0, N] | O(digits) |
| Convex Hull Trick | Linear DP optimization | O(n log n) |

---

## Study Order Recommendation

```
Week 1–2:  Array, String, Hash Table, Math
Week 3–4:  Binary Search, Two Pointers, Sliding Window
Week 5–6:  Linked List, Stack, Queue, Recursion
Week 7–8:  Trees (Binary Tree, BST, Trie)
Week 9–10: Graphs (BFS, DFS, Shortest Path, Topological Sort)
Week 11–12: Dynamic Programming (1D → 2D → Interval → Bitmask)
Week 13–14: Heap, Union-Find, Segment Tree, Monotonic structures
Week 15–16: Advanced Graph (SCC, Bridges, Max Flow), Advanced DP
```

---

## Complexity Quick Reference

| Algorithm | Time | Space |
|---|---|---|
| Sorting (comparison) | O(n log n) | O(1)–O(n) |
| Binary Search | O(log n) | O(1) |
| DFS / BFS | O(V + E) | O(V) |
| Dijkstra (min-heap) | O((V+E) log V) | O(V) |
| Bellman-Ford | O(VE) | O(V) |
| Floyd-Warshall | O(V³) | O(V²) |
| Kruskal | O(E log E) | O(V) |
| Prim (heap) | O((V+E) log V) | O(V) |
| Topological Sort | O(V + E) | O(V) |
| Tarjan SCC | O(V + E) | O(V) |
| Segment Tree | O(log n) query/update | O(n) |
| Fenwick Tree (BIT) | O(log n) query/update | O(n) |
| Union-Find (path compress) | O(α(n)) ≈ O(1) | O(n) |
| KMP | O(n + m) | O(m) |
| Manacher | O(n) | O(n) |
| FFT | O(n log n) | O(n) |

---

*Last updated: 2026 · Swift DSA Revision Notes · FAANG Interview Prep*
