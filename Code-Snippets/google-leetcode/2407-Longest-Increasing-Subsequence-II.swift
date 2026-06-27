// 2407. Longest Increasing Subsequence II
// https://leetcode.com/problems/longest-increasing-subsequence-ii
// Time Complexity: O(N * log(M)), where N is the number of elements in `nums` and M is the maximum value in `nums` (up to 10^5).
// For each element, we perform a segment tree query and update, both taking O(log M) time.
// Space Complexity: O(M), to store the segment tree array of size 4 * M.

class Solution {
    func lengthOfLIS(_ nums: [Int], _ k: Int) -> Int {
        guard let maxVal = nums.max() else { return 0 }
        
        // Segment tree array to store the maximum LIS length for values in range [1...maxVal]
        var tree = [Int](repeating: 0, count: 4 * maxVal + 1)
        
        // Update the segment tree: sets value at `index` to `val`
        func update(_ node: Int, _ start: Int, _ end: Int, _ index: Int, _ val: Int) {
            if start == end {
                tree[node] = max(tree[node], val) // Update with max length
                return
            }
            let mid = start + (end - start) / 2
            if index <= mid {
                update(node * 2, start, mid, index, val)
            } else {
                update(node * 2 + 1, mid + 1, end, index, val)
            }
            tree[node] = max(tree[node * 2], tree[node * 2 + 1])
        }
        
        // Query the segment tree: finds maximum LIS length in range [l...r]
        func query(_ node: Int, _ start: Int, _ end: Int, _ l: Int, _ r: Int) -> Int {
            if r < start || l > end {
                return 0 // Completely outside range
            }
            if l <= start && end <= r {
                return tree[node] // Completely inside range
            }
            let mid = start + (end - start) / 2
            let leftMax = query(node * 2, start, mid, l, r)
            let rightMax = query(node * 2 + 1, mid + 1, end, l, r)
            return max(leftMax, rightMax)
        }
        
        var ans = 1
        
        for num in nums {
            let left = max(1, num - k)
            let right = num - 1
            
            var maxLen = 0
            if right >= left {
                // Find the longest subsequence ending with a value between `num - k` and `num - 1`
                maxLen = query(1, 1, maxVal, left, right)
            }
            
            let newLen = maxLen + 1
            ans = max(ans, newLen)
            
            // Update the segment tree for `num` with `newLen`
            update(1, 1, maxVal, num, newLen)
        }
        
        return ans
    }
}
