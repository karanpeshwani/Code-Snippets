# Comprehensive DSA Topics & Techniques for FAANG Interviews

This document outlines the essential Data Structures and Algorithms (DSA) topics and techniques required for advanced coding interviews at FAANG and other top tech companies. The techniques are categorized primarily by the data structure they operate on, ranging from basic concepts to advanced algorithms.

## 1. Array
Arrays are the foundation of many problems. While the structure is simple, the techniques applied to them can be complex.
*   **Basic Operations:** Traversal, Insertion, Deletion.
*   **Two Pointers:** Opposite directional, same directional, fast/slow pointers.
*   **Sliding Window:** Fixed size, variable size (shrinkable/non-shrinkable).
*   **Prefix Sum / Suffix Sum:** O(1) range sum queries.
*   **Difference Array:** O(1) range update queries.
*   **Kadane's Algorithm:** Maximum subarray sum.
*   **Boyer-Moore Majority Vote Algorithm:** Finding majority elements in O(N) time and O(1) space.
*   **Dutch National Flag Algorithm:** Sorting arrays with 3 distinct values (e.g., 0s, 1s, and 2s).
*   **In-place Array Manipulation:** Swapping, reversing, cyclically shifting without extra space.
*   **Merge Intervals:** Sorting by start time and overlapping logic.
*   **Matrix Traversal:** Spiral matrix, diagonal traversal, rotating matrix.

## 2. String
Strings are essentially character arrays but come with their own set of specific algorithms, primarily for pattern matching and parsing.
*   **Two Pointers & Sliding Window:** Often applied to find substrings with specific properties.
*   **Anagrams and Palindromes:** Frequency counting, expanding from center.
*   **String Compression/Parsing:** Run-length encoding, parsing expressions.
*   **Substring Search (Pattern Matching):**
    *   Rabin-Karp Algorithm (Rolling Hash)
    *   KMP Algorithm (Knuth-Morris-Pratt)
    *   Z Algorithm
*   **Longest Common Subsequence / Substring** (Often overlaps with DP)

## 3. Linked List
Tests your ability to manipulate pointers safely.
*   **Dummy Node Technique:** Simplifying edge cases at the head of the list.
*   **Fast and Slow Pointers (Tortoise and Hare):** Cycle detection, finding the middle of the list.
*   **Reversing Linked List:** Iterative, Recursive, reversing in K-groups.
*   **Merging Linked Lists:** Merging two sorted lists, merging K sorted lists (using Heap/Divide & Conquer).
*   **Doubly-Linked List Manipulation:** Maintaining `prev` and `next` pointers (crucial for LRU/LFU cache design).

## 4. Hash Table
The go-to data structure for optimizing time complexity to O(1) lookups.
*   **Frequency Counting:** Counting occurrences of elements/characters.
*   **Two Sum / N-Sum Problems:** Using hashing to reduce time complexity.
*   **Caching / Memoization:** Storing previously computed results.
*   **Design Custom Data Structures:** Designing LRU Cache, LFU Cache, or Hash Map from scratch.
*   **Rolling Hash:** Used in string matching (Rabin-Karp).

## 5. Math & Bit Manipulation
Often used to optimize space or perform operations closer to the hardware level.
*   **Math:**
    *   Prime Factorization & Sieve of Eratosthenes.
    *   Greatest Common Divisor (GCD) & Euclidean Algorithm.
    *   Modular Arithmetic & Fast Exponentiation.
    *   Combinatorics (nCr, permutations).
    *   Geometry (Convex Hull - Advanced).
*   **Bit Manipulation:**
    *   Bitwise operators (AND, OR, XOR, NOT, Shifts).
    *   XOR tricks (e.g., finding single missing number, swapping without temp variable).
    *   Brian Kernighan’s Algorithm (Counting set bits).
    *   Bit Masking: Representing subsets or states as an integer.

## 6. Binary Search
Not just for searching in a sorted array, but an optimization technique for finding answers within a monotonic search space.
*   **Standard Binary Search:** Finding an element in a sorted array.
*   **Lower Bound / Upper Bound:** Finding the first or last occurrence.
*   **Binary Search on Answer Space:** "Minimize the maximum" or "Maximize the minimum" type problems.
*   **Rotated Sorted Array:** Searching or finding the minimum in a rotated array.
*   **Finding Peak Element:** Binary search on unsorted arrays based on local gradients.

## 7. Sorting
Understanding the underlying mechanics of sorting algorithms is crucial.
*   **Comparison Sorts:** Merge Sort (useful for counting inversions), Quick Sort, Heap Sort.
*   **Non-comparison Sorts:** Counting Sort, Radix Sort, Bucket Sort (O(N) time complexity under specific constraints).
*   **Quick Select:** Finding the Kth largest/smallest element in O(N) average time.
*   **Cycle Sort:** Minimum swaps to sort an array.

## 8. Stack & Queue
Linear data structures with specific order of operations.
*   **Stack (LIFO):** Validating parentheses, parsing expressions (Reverse Polish Notation), implementing recursion iteratively.
*   **Queue (FIFO):** BFS traversal, scheduling tasks.
*   **Monotonic Stack:** Finding Next Greater/Smaller element in O(N) time.
*   **Monotonic Queue (Double Ended Queue / Deque):** Sliding Window Maximum/Minimum problems.
*   **Design:** Implementing a Queue using Stacks, Min Stack / Max Stack (O(1) min/max retrieval).

## 9. Tree
Hierarchical data structures, primarily focusing on Binary Trees and Binary Search Trees.
*   **Traversals:** Inorder, Preorder, Postorder (Recursive and Iterative).
*   **Level Order Traversal (BFS):** Using a queue.
*   **Tree Properties:** Depth, height, diameter, balanced check.
*   **Lowest Common Ancestor (LCA):** In BST and standard Binary Tree.
*   **Tree Construction:** From Preorder/Inorder or Postorder/Inorder arrays.
*   **Binary Search Tree (BST):** Properties, insertion, deletion, validation.
*   **Advanced Trees:**
    *   **Trie (Prefix Tree):** Storing strings, autocomplete, dictionary implementations.
    *   **Segment Tree:** Range queries (sum, min, max) and point/range updates in O(log N).
    *   **Fenwick Tree (Binary Indexed Tree / BIT):** Simpler range sum queries and point updates in O(log N).

## 10. Graph Theory
Graphs model relationships. Problems can range from simple traversals to complex pathfinding.
*   **Representations:** Adjacency List, Adjacency Matrix.
*   **Traversals:**
    *   **Breadth-First Search (BFS):** Shortest path in unweighted graphs, level-by-level exploration.
    *   **Depth-First Search (DFS):** Pathfinding, exploring all possibilities.
*   **Topological Sorting:** Kahn's Algorithm (BFS based), DFS based. Used for dependency resolution.
*   **Cycle Detection:** In directed and undirected graphs.
*   **Bipartite Graph Check:** Graph coloring.
*   **Disjoint Set Union (DSU) / Union-Find:** Connected components, Kruskal's algorithm. Must know Path Compression and Union by Rank.
*   **Minimum Spanning Tree (MST):**
    *   Kruskal's Algorithm (using DSU).
    *   Prim's Algorithm (using Priority Queue).
*   **Shortest Path Algorithms:**
    *   Dijkstra's Algorithm: Single source shortest path (non-negative weights).
    *   Bellman-Ford Algorithm: Single source shortest path (handles negative weights, detects negative cycles).
    *   Floyd-Warshall Algorithm: All-pairs shortest path (DP based).
*   **Advanced Graph Algorithms:**
    *   Strongly Connected Components (Tarjan's or Kosaraju's Algorithm).
    *   Articulation Points and Bridges.
    *   Network Flow (Ford-Fulkerson) (Rarely asked, but good to know for top tier).

## 11. Heaps (Priority Queue)
Used for maintaining the maximum or minimum element dynamically.
*   **Min Heap / Max Heap Properties.**
*   **Top K Elements:** Finding the Kth largest/smallest or K most frequent elements.
*   **Merge K Sorted Lists:** Using a heap to efficiently merge.
*   **Two Heaps Pattern:** Finding the median from a continuous data stream.
*   **Interval Scheduling:** Meeting rooms, CPU task scheduling.

## 12. Dynamic Programming (DP)
Solving complex problems by breaking them down into simpler subproblems.
*   **Core Concepts:** Overlapping Subproblems, Optimal Substructure, State Definition, State Transitions.
*   **Approaches:**
    *   Memoization (Top-Down Recursive).
    *   Tabulation (Bottom-Up Iterative).
    *   Space Optimization (reducing 2D DP to 1D array or variables).
*   **Common DP Patterns:**
    *   1D DP (Fibonacci, Climbing Stairs, House Robber).
    *   2D DP / Grid DP (Unique Paths, Minimum Path Sum).
    *   Knapsack Problems (0/1 Knapsack, Unbounded Knapsack, Coin Change).
    *   Longest Common Subsequence (LCS) / Longest Increasing Subsequence (LIS).
    *   Palindrome DP (Longest Palindromic Substring/Subsequence).
    *   DP on Strings (Edit Distance, Wildcard Matching).
    *   Interval DP (Matrix Chain Multiplication).
*   **Advanced DP:**
    *   Bitmask DP (Traveling Salesperson Problem variations).
    *   DP on Trees.
    *   Digit DP.

## 13. Recursion & Backtracking
Exploring all potential solutions and abandoning paths that fail constraints.
*   **Combinatorial Search:** Generating subsets (Power Set), Permutations, Combinations.
*   **Constraint Satisfaction:** N-Queens Problem, Sudoku Solver.
*   **Graph/Grid Backtracking:** Word Search, Rat in a Maze.
*   **Pruning:** Optimizing backtracking by terminating invalid paths early.
