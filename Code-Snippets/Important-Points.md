# Important Points

**Swift Sorting Closures (`<` vs `<=`):** Always use strict operators (`<` or `>`). Never use `<=` or `>=`, as comparing identical elements returns `true` (e.g., `5 <= 5`), breaking the "Strict Weak Ordering" rule. Lying to the sorting algorithm this way can cause memory crashes, infinite loops, or incorrectly sorted arrays.
* **Safe:** `arr.sorted { $0 < $1 }`
* **Unsafe (Can crash):** `arr.sorted { $0 <= $1 }`
