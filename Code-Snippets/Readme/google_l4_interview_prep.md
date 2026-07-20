# Google L4 SWE Interview Prep — LeetCode Question Bank

> Compiled from Reddit interview experiences (2024–2026) + LeetCode discuss posts on Google L4 SWE patterns.
> LeetCode discuss pages require login; all signal extracted from the pasted Reddit posts and pattern-mapped to canonical LC problems.

---

## 📊 Most Frequently Asked Topics (Ranked by Frequency)

| Rank | Topic | Frequency Signal |
|------|-------|-----------------|
| 1 | **Graphs** (Dijkstra, BFS, DFS, Connected Components) | ⭐⭐⭐⭐⭐ Mentioned in nearly every technical round |
| 2 | **Intervals** (Merge, Insert, Range overlap) | ⭐⭐⭐⭐⭐ Multiple posts, multiple rounds |
| 3 | **Hash Maps / Hash Sets** | ⭐⭐⭐⭐ Used as core DS in most solutions |
| 4 | **Greedy** | ⭐⭐⭐⭐ Huffman, two-pointer, interval scheduling |
| 5 | **Heap / Priority Queue** | ⭐⭐⭐⭐ Heap-based onsite round mentioned explicitly |
| 6 | **Topological Sort** | ⭐⭐⭐ Two separate posts mention it as a standalone round topic |
| 7 | **Design / OOP** (LFU, LRU, Text Editor, Cache) | ⭐⭐⭐ "Design-flavored" rounds mentioned as differentiator |
| 8 | **Sliding Window / Two Pointers** | ⭐⭐⭐ Phone screen staple |
| 9 | **Dynamic Programming** | ⭐⭐⭐ Onsite round with DP + backtracking |
| 10 | **Trees / BST** | ⭐⭐⭐ Multiple posts with tree-based problems |
| 11 | **Prefix Sum** | ⭐⭐ Phone screen (array + prefix sum post) |
| 12 | **Trie** | ⭐⭐ DFS + Trie onsite round |
| 13 | **Stack** | ⭐⭐ Stack + BST design problem |
| 14 | **Union Find** | ⭐⭐ Disconnected subgraphs / connected components |
| 15 | **Backtracking** | ⭐ DP + backtracking combined onsite |
| 16 | **Binary Search** | ⭐ Swim in Rising Water variant (BFS + Binary Search) |
| 17 | **String Manipulation** | ⭐ String compression + frequency counting |

---

## 🔑 Key Takeaways from Reddit Posts

1. **Communication > Speed** — Multiple posts say weak communication killed rounds even with correct solutions.
2. **Brute-force → Optimal progression** is expected — show you can reason up to the efficient solution.
3. **Edge cases are a hard requirement** — Missing edge cases was cited as a rejection reason in 3+ posts.
4. **OOP/class structure matters** — One candidate was rejected despite a correct LFU solution because it wasn't structured into clean classes.
5. **Complexity analysis must be accurate** — Being wrong on TC/SC then self-correcting is ok; never correcting is not.
6. **NeetCode 150 is the consensus baseline** — Most successful candidates cite NC150 + targeted graph drilling.
7. **Focus heavily on Mediums** — Multiple posts say LC Mediums dominate; Hards appear but aren't the majority.

---

## 📋 LeetCode Question List (JSON)

```json
[
  {
    "topic": "Graphs — Dijkstra",
    "name": "Network Delay Time",
    "link": "https://leetcode.com/problems/network-delay-time/",
    "difficulty": "Medium",
    "why": "Core Dijkstra — explicitly mentioned as the algorithm asked in two separate coding rounds"
  },
  {
    "topic": "Graphs — Dijkstra",
    "name": "Cheapest Flights Within K Stops",
    "link": "https://leetcode.com/problems/cheapest-flights-within-k-stops/",
    "difficulty": "Medium",
    "why": "Dijkstra/BFS on weighted graph with constraints — matches 'weighted graph' phone screen described"
  },
  {
    "topic": "Graphs — Dijkstra / Binary Search",
    "name": "Path With Minimum Effort",
    "link": "https://leetcode.com/problems/path-with-minimum-effort/",
    "difficulty": "Medium",
    "why": "Solvable via Dijkstra or Binary Search + BFS — matches the 'solve using BFS or Dijkstra' pattern"
  },
  {
    "topic": "Graphs — BFS / Binary Search",
    "name": "Swim in Rising Water",
    "link": "https://leetcode.com/problems/swim-in-rising-water/",
    "difficulty": "Hard",
    "why": "Explicitly named as a variation asked in an onsite round"
  },
  {
    "topic": "Graphs — Multi-source BFS",
    "name": "Rotting Oranges",
    "link": "https://leetcode.com/problems/rotting-oranges/",
    "difficulty": "Medium",
    "why": "Multi-source BFS — a topic explicitly called out as important in graph rounds"
  },
  {
    "topic": "Graphs — Multi-source BFS",
    "name": "01 Matrix",
    "link": "https://leetcode.com/problems/01-matrix/",
    "difficulty": "Medium",
    "why": "Multi-source BFS pattern — directly matches the 'multi-source BFS' topic mentioned"
  },
  {
    "topic": "Graphs — Connected Components",
    "name": "Number of Islands",
    "link": "https://leetcode.com/problems/number-of-islands/",
    "difficulty": "Medium",
    "why": "Connected components via DFS/BFS — foundational pattern for the graph rounds described"
  },
  {
    "topic": "Graphs — Connected Components",
    "name": "Number of Connected Components in an Undirected Graph",
    "link": "https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/",
    "difficulty": "Medium",
    "why": "One post describes exactly this: 'finding number of disconnected subgraphs, array with edge from index i to arr[i]'"
  },
  {
    "topic": "Graphs — BFS/DFS",
    "name": "Pacific Atlantic Water Flow",
    "link": "https://leetcode.com/problems/pacific-atlantic-water-flow/",
    "difficulty": "Medium",
    "why": "Multi-source BFS/DFS from boundaries — trains the multi-directional BFS pattern"
  },
  {
    "topic": "Graphs — BFS/DFS",
    "name": "Shortest Path in Binary Matrix",
    "link": "https://leetcode.com/problems/shortest-path-in-binary-matrix/",
    "difficulty": "Medium",
    "why": "BFS shortest path — core graph traversal pattern"
  },
  {
    "topic": "Graphs — BFS + Filesystem",
    "name": "Walls and Gates",
    "link": "https://leetcode.com/problems/walls-and-gates/",
    "difficulty": "Medium",
    "why": "Multi-source BFS — matches 'filesystem BFS/DFS' round described"
  },
  {
    "topic": "Graphs — Weighted / MST",
    "name": "Minimum Cost to Connect All Points",
    "link": "https://leetcode.com/problems/minimum-cost-to-connect-all-points/",
    "difficulty": "Medium",
    "why": "MST (Prim's/Kruskal's) on weighted graph — graph round prep"
  },
  {
    "topic": "Topological Sort",
    "name": "Course Schedule",
    "link": "https://leetcode.com/problems/course-schedule/",
    "difficulty": "Medium",
    "why": "Explicitly named: 'basically Course Schedule I + II combined' — Kahn's algorithm, cycle detection"
  },
  {
    "topic": "Topological Sort",
    "name": "Course Schedule II",
    "link": "https://leetcode.com/problems/course-schedule-ii/",
    "difficulty": "Medium",
    "why": "Explicitly named: return actual topological ordering — Kahn's algorithm"
  },
  {
    "topic": "Topological Sort",
    "name": "Alien Dictionary",
    "link": "https://leetcode.com/problems/alien-dictionary/",
    "difficulty": "Hard",
    "why": "Advanced topo sort — trains cycle detection + ordering derivation from constraints"
  },
  {
    "topic": "Topological Sort",
    "name": "Find All Possible Recipes from Given Supplies",
    "link": "https://leetcode.com/problems/find-all-possible-recipes-from-given-supplies/",
    "difficulty": "Medium",
    "why": "Real-world topo sort with dependency resolution — matches Google's 'disguised' problem style"
  },
  {
    "topic": "Topological Sort",
    "name": "Parallel Courses",
    "link": "https://leetcode.com/problems/parallel-courses/",
    "difficulty": "Medium",
    "why": "BFS-based topo sort with level tracking"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Minimum Cost to Connect Sticks",
    "link": "https://leetcode.com/problems/minimum-cost-to-connect-sticks/",
    "difficulty": "Medium",
    "why": "Huffman encoding greedy pattern — post explicitly describes a 'Huffman encoding variant' onsite round"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Task Scheduler",
    "link": "https://leetcode.com/problems/task-scheduler/",
    "difficulty": "Medium",
    "why": "Greedy + heap scheduling — trains the greedy heap reasoning path from brute-force to optimal"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Find Median from Data Stream",
    "link": "https://leetcode.com/problems/find-median-from-data-stream/",
    "difficulty": "Hard",
    "why": "Two-heap data stream design — matches 'data stream manipulation' onsite"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Top K Frequent Elements",
    "link": "https://leetcode.com/problems/top-k-frequent-elements/",
    "difficulty": "Medium",
    "why": "Heap + frequency counting — common phone screen pattern"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Merge K Sorted Lists",
    "link": "https://leetcode.com/problems/merge-k-sorted-lists/",
    "difficulty": "Hard",
    "why": "Min-heap merging — heap fundamentals for Dijkstra-related rounds"
  },
  {
    "topic": "Heap / Priority Queue",
    "name": "Reorganize String",
    "link": "https://leetcode.com/problems/reorganize-string/",
    "difficulty": "Medium",
    "why": "Greedy + max-heap — trains the greedy-from-heap approach"
  },
  {
    "topic": "Design — LFU / LRU",
    "name": "LFU Cache",
    "link": "https://leetcode.com/problems/lfu-cache/",
    "difficulty": "Hard",
    "why": "Explicitly asked as a variant in TWO separate onsite posts. One candidate was rejected for not using clean OOP structure on this exact problem."
  },
  {
    "topic": "Design — LFU / LRU",
    "name": "LRU Cache",
    "link": "https://leetcode.com/problems/lru-cache/",
    "difficulty": "Medium",
    "why": "Prerequisite to LFU — doubly linked list + hashmap design"
  },
  {
    "topic": "Design — Data Structures",
    "name": "Design Twitter",
    "link": "https://leetcode.com/problems/design-twitter/",
    "difficulty": "Medium",
    "why": "OOP class design with heap — matches the 'class design problem with requirements' interview described"
  },
  {
    "topic": "Design — Range / Stream",
    "name": "Data Stream as Disjoint Intervals",
    "link": "https://leetcode.com/problems/data-stream-as-disjoint-intervals/",
    "difficulty": "Hard",
    "why": "Matches: 'implement a class acting as an API to store and retrieve messages within a certain time frame'"
  },
  {
    "topic": "Design — Range / Stream",
    "name": "My Calendar I",
    "link": "https://leetcode.com/problems/my-calendar-i/",
    "difficulty": "Medium",
    "why": "Class design with interval management — overlaps with the bookkeeping/text-editor-style design rounds"
  },
  {
    "topic": "Design — Range / Stream",
    "name": "My Calendar II",
    "link": "https://leetcode.com/problems/my-calendar-ii/",
    "difficulty": "Medium",
    "why": "Extension of My Calendar I with more complex overlap tracking"
  },
  {
    "topic": "Design — Range / Stream",
    "name": "Range Sum Query — Mutable",
    "link": "https://leetcode.com/problems/range-sum-query-mutable/",
    "difficulty": "Medium",
    "why": "Design with efficient range queries — segment tree / BIT"
  },
  {
    "topic": "Intervals",
    "name": "Merge Intervals",
    "link": "https://leetcode.com/problems/merge-intervals/",
    "difficulty": "Medium",
    "why": "Directly mentioned: 'medium level question related to merge intervals was asked' in phone screen"
  },
  {
    "topic": "Intervals",
    "name": "Insert Interval",
    "link": "https://leetcode.com/problems/insert-interval/",
    "difficulty": "Medium",
    "why": "Interval insertion and merging — same pattern as merge intervals"
  },
  {
    "topic": "Intervals",
    "name": "Non-overlapping Intervals",
    "link": "https://leetcode.com/problems/non-overlapping-intervals/",
    "difficulty": "Medium",
    "why": "Greedy interval scheduling — matches the 'intervals problem' phone screen round"
  },
  {
    "topic": "Intervals",
    "name": "Meeting Rooms II",
    "link": "https://leetcode.com/problems/meeting-rooms-ii/",
    "difficulty": "Medium",
    "why": "Min-heap + interval overlap — heap + interval combo"
  },
  {
    "topic": "Intervals",
    "name": "Employee Free Time",
    "link": "https://leetcode.com/problems/employee-free-time/",
    "difficulty": "Hard",
    "why": "Advanced intervals: merge + find gaps — matches 'medium-hard' intervals round"
  },
  {
    "topic": "Intervals",
    "name": "Minimum Number of Arrows to Burst Balloons",
    "link": "https://leetcode.com/problems/minimum-number-of-arrows-to-burst-balloons/",
    "difficulty": "Medium",
    "why": "Greedy interval overlap — common Google interval variant"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Longest Substring Without Repeating Characters",
    "link": "https://leetcode.com/problems/longest-substring-without-repeating-characters/",
    "difficulty": "Medium",
    "why": "Sliding window + hashset — mentioned as a phone screen: 'sliding window and hashing question'"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Minimum Window Substring",
    "link": "https://leetcode.com/problems/minimum-window-substring/",
    "difficulty": "Hard",
    "why": "Sliding window + frequency hash map — advanced version of the sliding window pattern"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Longest Repeating Character Replacement",
    "link": "https://leetcode.com/problems/longest-repeating-character-replacement/",
    "difficulty": "Medium",
    "why": "Sliding window + frequency tracking"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Find All Anagrams in a String",
    "link": "https://leetcode.com/problems/find-all-anagrams-in-a-string/",
    "difficulty": "Medium",
    "why": "Fixed-size sliding window + frequency map"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Sliding Window Maximum",
    "link": "https://leetcode.com/problems/sliding-window-maximum/",
    "difficulty": "Hard",
    "why": "Deque-based sliding window — harder follow-up variant"
  },
  {
    "topic": "Sliding Window / Two Pointers",
    "name": "Container With Most Water",
    "link": "https://leetcode.com/problems/container-with-most-water/",
    "difficulty": "Medium",
    "why": "Two-pointer greedy — classic Google phone screen"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Coin Change",
    "link": "https://leetcode.com/problems/coin-change/",
    "difficulty": "Medium",
    "why": "Foundational DP — bottom-up tabulation"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Longest Common Subsequence",
    "link": "https://leetcode.com/problems/longest-common-subsequence/",
    "difficulty": "Medium",
    "why": "2D DP — matches 'path/subsequence-related thinking' in onsite"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Word Break",
    "link": "https://leetcode.com/problems/word-break/",
    "difficulty": "Medium",
    "why": "DP + string — common Google DP problem"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Decode Ways",
    "link": "https://leetcode.com/problems/decode-ways/",
    "difficulty": "Medium",
    "why": "DP with string generation — matches 'string generation' in onsite description"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Unique Paths II",
    "link": "https://leetcode.com/problems/unique-paths-ii/",
    "difficulty": "Medium",
    "why": "Grid DP — path-based DP pattern"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Longest Increasing Subsequence",
    "link": "https://leetcode.com/problems/longest-increasing-subsequence/",
    "difficulty": "Medium",
    "why": "Classic DP + binary search optimization"
  },
  {
    "topic": "Dynamic Programming",
    "name": "Edit Distance",
    "link": "https://leetcode.com/problems/edit-distance/",
    "difficulty": "Medium",
    "why": "2D string DP — common Google DP"
  },
  {
    "topic": "DP + Backtracking",
    "name": "Palindrome Partitioning",
    "link": "https://leetcode.com/problems/palindrome-partitioning/",
    "difficulty": "Medium",
    "why": "DP + backtracking combined — matches 'DP, backtracking, string generation, unique permutations wrapped into one'"
  },
  {
    "topic": "DP + Backtracking",
    "name": "Word Break II",
    "link": "https://leetcode.com/problems/word-break-ii/",
    "difficulty": "Hard",
    "why": "DP + backtracking for string generation — direct match for onsite description"
  },
  {
    "topic": "DP + Backtracking",
    "name": "Permutations II",
    "link": "https://leetcode.com/problems/permutations-ii/",
    "difficulty": "Medium",
    "why": "Backtracking with duplicate handling — 'unique permutations' explicitly mentioned"
  },
  {
    "topic": "DP + Backtracking",
    "name": "Combination Sum",
    "link": "https://leetcode.com/problems/combination-sum/",
    "difficulty": "Medium",
    "why": "Backtracking — foundational pattern"
  },
  {
    "topic": "Trees / BST",
    "name": "Validate Binary Search Tree",
    "link": "https://leetcode.com/problems/validate-binary-search-tree/",
    "difficulty": "Medium",
    "why": "BST fundamentals — verbal BST question asked in phone screen"
  },
  {
    "topic": "Trees / BST",
    "name": "Kth Smallest Element in a BST",
    "link": "https://leetcode.com/problems/kth-smallest-element-in-a-bst/",
    "difficulty": "Medium",
    "why": "BST inorder traversal — BST + heap design problem mentioned"
  },
  {
    "topic": "Trees / BST",
    "name": "Binary Tree Level Order Traversal",
    "link": "https://leetcode.com/problems/binary-tree-level-order-traversal/",
    "difficulty": "Medium",
    "why": "BFS on trees — core tree traversal pattern"
  },
  {
    "topic": "Trees / BST",
    "name": "Serialize and Deserialize Binary Tree",
    "link": "https://leetcode.com/problems/serialize-and-deserialize-binary-tree/",
    "difficulty": "Hard",
    "why": "Tree design problem — matches 'tree + hashMap' medium-hard design pattern"
  },
  {
    "topic": "Trees / BST",
    "name": "Lowest Common Ancestor of a Binary Tree",
    "link": "https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/",
    "difficulty": "Medium",
    "why": "Classic tree recursion — common Google tree problem"
  },
  {
    "topic": "Trees / BST",
    "name": "Binary Tree Right Side View",
    "link": "https://leetcode.com/problems/binary-tree-right-side-view/",
    "difficulty": "Medium",
    "why": "BFS level order — practical tree traversal"
  },
  {
    "topic": "Trees / BST",
    "name": "Construct Binary Tree from Preorder and Inorder Traversal",
    "link": "https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/",
    "difficulty": "Medium",
    "why": "Tree construction + hashmap — matches 'tree + hashMap' onsite"
  },
  {
    "topic": "Trie",
    "name": "Implement Trie (Prefix Tree)",
    "link": "https://leetcode.com/problems/implement-trie-prefix-tree/",
    "difficulty": "Medium",
    "why": "Foundational Trie — explicitly mentioned: 'DFS + Trie' onsite round"
  },
  {
    "topic": "Trie",
    "name": "Word Search II",
    "link": "https://leetcode.com/problems/word-search-ii/",
    "difficulty": "Hard",
    "why": "DFS + Trie combined — direct match for 'DFS + Trie implementation-heavy' onsite"
  },
  {
    "topic": "Trie",
    "name": "Design Add and Search Words Data Structure",
    "link": "https://leetcode.com/problems/design-add-and-search-words-data-structure/",
    "difficulty": "Medium",
    "why": "Trie with wildcard DFS — design-flavor Trie problem"
  },
  {
    "topic": "Stack",
    "name": "Min Stack",
    "link": "https://leetcode.com/problems/min-stack/",
    "difficulty": "Medium",
    "why": "Stack design — 'Stack + BST design problem' in phone screen"
  },
  {
    "topic": "Stack",
    "name": "Daily Temperatures",
    "link": "https://leetcode.com/problems/daily-temperatures/",
    "difficulty": "Medium",
    "why": "Monotonic stack — common stack pattern"
  },
  {
    "topic": "Stack",
    "name": "Decode String",
    "link": "https://leetcode.com/problems/decode-string/",
    "difficulty": "Medium",
    "why": "Stack-based string decompression — matches 'string compression/decompression' phone screen"
  },
  {
    "topic": "String / Frequency",
    "name": "String Compression",
    "link": "https://leetcode.com/problems/string-compression/",
    "difficulty": "Easy",
    "why": "String compression — directly mentioned: 'string compression/decompression + frequency counting'"
  },
  {
    "topic": "String / Frequency",
    "name": "Group Anagrams",
    "link": "https://leetcode.com/problems/group-anagrams/",
    "difficulty": "Medium",
    "why": "HashMap + string frequency — core hashing pattern"
  },
  {
    "topic": "String / Frequency",
    "name": "Longest Palindromic Substring",
    "link": "https://leetcode.com/problems/longest-palindromic-substring/",
    "difficulty": "Medium",
    "why": "String DP / expand around center — common Google string problem"
  },
  {
    "topic": "Prefix Sum",
    "name": "Subarray Sum Equals K",
    "link": "https://leetcode.com/problems/subarray-sum-equals-k/",
    "difficulty": "Medium",
    "why": "Prefix sum + hashmap — matches 'array and prefix sum' phone screen"
  },
  {
    "topic": "Prefix Sum",
    "name": "Product of Array Except Self",
    "link": "https://leetcode.com/problems/product-of-array-except-self/",
    "difficulty": "Medium",
    "why": "Prefix/suffix product — classic Google array problem"
  },
  {
    "topic": "Prefix Sum",
    "name": "Range Sum Query — Immutable",
    "link": "https://leetcode.com/problems/range-sum-query-immutable/",
    "difficulty": "Easy",
    "why": "Foundational prefix sum — prerequisite for range problems"
  },
  {
    "topic": "Union Find",
    "name": "Redundant Connection",
    "link": "https://leetcode.com/problems/redundant-connection/",
    "difficulty": "Medium",
    "why": "Union Find cycle detection — connected components alternative approach"
  },
  {
    "topic": "Union Find",
    "name": "Accounts Merge",
    "link": "https://leetcode.com/problems/accounts-merge/",
    "difficulty": "Medium",
    "why": "Union Find with grouping — real-world Google-style problem"
  },
  {
    "topic": "Graph + DP",
    "name": "Unique Paths",
    "link": "https://leetcode.com/problems/unique-paths/",
    "difficulty": "Medium",
    "why": "Grid DP/graph — 'Graph + DP recurrence formula' asked as follow-up"
  },
  {
    "topic": "Graph + DP",
    "name": "Minimum Path Sum",
    "link": "https://leetcode.com/problems/minimum-path-sum/",
    "difficulty": "Medium",
    "why": "Grid DP with path tracking — graph + DP onsite pattern"
  },
  {
    "topic": "Binary Search",
    "name": "Search in Rotated Sorted Array",
    "link": "https://leetcode.com/problems/search-in-rotated-sorted-array/",
    "difficulty": "Medium",
    "why": "Binary search — mentioned alongside 'frequency counting + binary search' in phone screen"
  },
  {
    "topic": "Binary Search",
    "name": "Koko Eating Bananas",
    "link": "https://leetcode.com/problems/koko-eating-bananas/",
    "difficulty": "Medium",
    "why": "Binary search on answer — common Google binary search pattern"
  },
  {
    "topic": "Binary Search",
    "name": "Find Minimum in Rotated Sorted Array",
    "link": "https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/",
    "difficulty": "Medium",
    "why": "Binary search variant — core binary search prep"
  },
  {
    "topic": "HashMap / Two Maps",
    "name": "Two Sum",
    "link": "https://leetcode.com/problems/two-sum/",
    "difficulty": "Easy",
    "why": "HashMap lookup — 'quickly crank out the problem using 2 maps' mentioned"
  },
  {
    "topic": "HashMap / Two Maps",
    "name": "4Sum II",
    "link": "https://leetcode.com/problems/4sum-ii/",
    "difficulty": "Medium",
    "why": "Two hashmap approach — matches '2 maps' solution pattern"
  },
  {
    "topic": "HashMap / Two Maps",
    "name": "Isomorphic Strings",
    "link": "https://leetcode.com/problems/isomorphic-strings/",
    "difficulty": "Easy",
    "why": "Bidirectional hashmap — classic two-map pattern"
  },
  {
    "topic": "Greedy",
    "name": "Jump Game II",
    "link": "https://leetcode.com/problems/jump-game-ii/",
    "difficulty": "Medium",
    "why": "Greedy approach — trains 'prove greedy is correct' reasoning"
  },
  {
    "topic": "Greedy",
    "name": "Gas Station",
    "link": "https://leetcode.com/problems/gas-station/",
    "difficulty": "Medium",
    "why": "Greedy with intuition — non-obvious greedy choice"
  },
  {
    "topic": "Greedy",
    "name": "Partition Labels",
    "link": "https://leetcode.com/problems/partition-labels/",
    "difficulty": "Medium",
    "why": "Greedy interval-style — 'two-pointers/greedy unique pattern' phone screen"
  },
  {
    "topic": "Greedy",
    "name": "Hand of Straights",
    "link": "https://leetcode.com/problems/hand-of-straights/",
    "difficulty": "Medium",
    "why": "Greedy + sorted map — non-obvious greedy"
  }
]
```

---

## 🗂️ Questions by Topic (Quick Reference)

### 🔵 Graphs (HIGHEST PRIORITY)
| Problem | Difficulty | Link |
|---------|-----------|------|
| Network Delay Time | Medium | https://leetcode.com/problems/network-delay-time/ |
| Cheapest Flights Within K Stops | Medium | https://leetcode.com/problems/cheapest-flights-within-k-stops/ |
| Path With Minimum Effort | Medium | https://leetcode.com/problems/path-with-minimum-effort/ |
| Swim in Rising Water | Hard | https://leetcode.com/problems/swim-in-rising-water/ |
| Rotting Oranges | Medium | https://leetcode.com/problems/rotting-oranges/ |
| 01 Matrix | Medium | https://leetcode.com/problems/01-matrix/ |
| Number of Islands | Medium | https://leetcode.com/problems/number-of-islands/ |
| Number of Connected Components | Medium | https://leetcode.com/problems/number-of-connected-components-in-an-undirected-graph/ |
| Pacific Atlantic Water Flow | Medium | https://leetcode.com/problems/pacific-atlantic-water-flow/ |
| Shortest Path in Binary Matrix | Medium | https://leetcode.com/problems/shortest-path-in-binary-matrix/ |
| Minimum Cost to Connect All Points | Medium | https://leetcode.com/problems/minimum-cost-to-connect-all-points/ |

### 🟣 Topological Sort
| Problem | Difficulty | Link |
|---------|-----------|------|
| Course Schedule | Medium | https://leetcode.com/problems/course-schedule/ |
| Course Schedule II | Medium | https://leetcode.com/problems/course-schedule-ii/ |
| Alien Dictionary | Hard | https://leetcode.com/problems/alien-dictionary/ |
| Find All Possible Recipes | Medium | https://leetcode.com/problems/find-all-possible-recipes-from-given-supplies/ |
| Parallel Courses | Medium | https://leetcode.com/problems/parallel-courses/ |

### 🟡 Intervals
| Problem | Difficulty | Link |
|---------|-----------|------|
| Merge Intervals | Medium | https://leetcode.com/problems/merge-intervals/ |
| Insert Interval | Medium | https://leetcode.com/problems/insert-interval/ |
| Non-overlapping Intervals | Medium | https://leetcode.com/problems/non-overlapping-intervals/ |
| Meeting Rooms II | Medium | https://leetcode.com/problems/meeting-rooms-ii/ |
| Employee Free Time | Hard | https://leetcode.com/problems/employee-free-time/ |
| Min Arrows to Burst Balloons | Medium | https://leetcode.com/problems/minimum-number-of-arrows-to-burst-balloons/ |

### 🟠 Heap / Priority Queue
| Problem | Difficulty | Link |
|---------|-----------|------|
| Minimum Cost to Connect Sticks | Medium | https://leetcode.com/problems/minimum-cost-to-connect-sticks/ |
| Task Scheduler | Medium | https://leetcode.com/problems/task-scheduler/ |
| Find Median from Data Stream | Hard | https://leetcode.com/problems/find-median-from-data-stream/ |
| Top K Frequent Elements | Medium | https://leetcode.com/problems/top-k-frequent-elements/ |
| Merge K Sorted Lists | Hard | https://leetcode.com/problems/merge-k-sorted-lists/ |
| Reorganize String | Medium | https://leetcode.com/problems/reorganize-string/ |

### 🔴 Design / OOP (Google differentiator — drill these!)
| Problem | Difficulty | Link |
|---------|-----------|------|
| LFU Cache | Hard | https://leetcode.com/problems/lfu-cache/ |
| LRU Cache | Medium | https://leetcode.com/problems/lru-cache/ |
| Design Twitter | Medium | https://leetcode.com/problems/design-twitter/ |
| Data Stream as Disjoint Intervals | Hard | https://leetcode.com/problems/data-stream-as-disjoint-intervals/ |
| My Calendar I | Medium | https://leetcode.com/problems/my-calendar-i/ |
| My Calendar II | Medium | https://leetcode.com/problems/my-calendar-ii/ |

### 🟢 Dynamic Programming
| Problem | Difficulty | Link |
|---------|-----------|------|
| Coin Change | Medium | https://leetcode.com/problems/coin-change/ |
| Longest Common Subsequence | Medium | https://leetcode.com/problems/longest-common-subsequence/ |
| Word Break | Medium | https://leetcode.com/problems/word-break/ |
| Word Break II | Hard | https://leetcode.com/problems/word-break-ii/ |
| Decode Ways | Medium | https://leetcode.com/problems/decode-ways/ |
| Longest Increasing Subsequence | Medium | https://leetcode.com/problems/longest-increasing-subsequence/ |
| Edit Distance | Medium | https://leetcode.com/problems/edit-distance/ |
| Palindrome Partitioning | Medium | https://leetcode.com/problems/palindrome-partitioning/ |

### ⚪ Sliding Window / Two Pointers
| Problem | Difficulty | Link |
|---------|-----------|------|
| Longest Substring Without Repeating | Medium | https://leetcode.com/problems/longest-substring-without-repeating-characters/ |
| Minimum Window Substring | Hard | https://leetcode.com/problems/minimum-window-substring/ |
| Longest Repeating Char Replacement | Medium | https://leetcode.com/problems/longest-repeating-character-replacement/ |
| Find All Anagrams | Medium | https://leetcode.com/problems/find-all-anagrams-in-a-string/ |
| Sliding Window Maximum | Hard | https://leetcode.com/problems/sliding-window-maximum/ |
| Container With Most Water | Medium | https://leetcode.com/problems/container-with-most-water/ |

---

## 📅 Suggested 1-Week Study Plan

| Day | Focus | Problems |
|-----|-------|----------|
| **Day 1** | Graphs Core | Network Delay Time, Cheapest Flights, Number of Islands, Connected Components, Rotting Oranges |
| **Day 2** | Graphs Advanced + Topo Sort | Swim in Rising Water, Pacific Atlantic, Course Schedule I+II, Alien Dictionary |
| **Day 3** | Design (highest Google differentiator) | LRU Cache, **LFU Cache** (with clean OOP!), Data Stream as Disjoint Intervals, My Calendar I/II |
| **Day 4** | Intervals + Heap | Merge Intervals, Insert Interval, Meeting Rooms II, Min Cost Connect Sticks (Huffman), Task Scheduler, Find Median |
| **Day 5** | DP + Backtracking | Word Break I+II, Palindrome Partitioning, Permutations II, Decode Ways, Edit Distance |
| **Day 6** | Sliding Window + Trees + Trie | Min Window Substring, Sliding Window Max, Validate BST, Word Search II, Implement Trie |
| **Day 7** | Mock interviews + Weak areas | 2–3 full mock sessions with time pressure; focus on communicating complexity and edge cases aloud |

---

## ⚠️ Critical Google-Specific Interview Tips

1. **Never jump to code immediately** — spend 3–5 min clarifying, stating assumptions, walking through examples
2. **LFU Cache: write it as classes** — one rejection explicitly cited "didn't use proper OOP structure"
3. **Dijkstra = PQ + visited set** — know it cold; wrong algo choice when you said Dijkstra is recoverable if you explain why; wrong algo + no explanation is fatal
4. **State time AND space complexity for every approach** — brute force AND optimized
5. **Edge cases out loud before coding** — empty input, single element, all same, negative weights, cycles
6. **Code modularly** — break into helper functions; "writing all code in one function" was flagged as a negative even with correct logic
7. **After coding: dry run with a test case** — interviewers appreciated this in multiple posts
8. **For greedy problems: explain why greedy works** — don't just use it, prove the exchange argument briefly

---

*Generated from analysis of Google L4 SWE interview experiences (2024–2026)*
*LeetCode discuss pages (403 gated) — signal extracted from Reddit posts only*
