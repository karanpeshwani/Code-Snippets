# Important Points

**Swift Sorting Closures (`<` vs `<=`):** Always use strict operators (`<` or `>`). Never use `<=` or `>=`, as comparing identical elements returns `true` (e.g., `5 <= 5`), breaking the "Strict Weak Ordering" rule. Lying to the sorting algorithm this way can cause memory crashes, infinite loops, or incorrectly sorted arrays.
* **Safe:** `arr.sorted { $0 < $1 }`
* **Unsafe (Can crash):** `arr.sorted { $0 <= $1 }`

**Hashing in Swift (Classes & Structs):** 
Never include mutable properties (`var`) in your `Hashable` or `Equatable` implementations. If a hashed property changes while stored in a `Dictionary` or `Set`, the collection loses track of the object, causing memory leaks or silent failures. 
* **Classes:** Manually implement `hash(into:)` and `==` using only constant (`let`) identity properties. 
* **Structs:** Explicitly implement `Hashable` to exclude `var` properties, because Swift's auto-synthesized `Hashable` includes all properties by default.
