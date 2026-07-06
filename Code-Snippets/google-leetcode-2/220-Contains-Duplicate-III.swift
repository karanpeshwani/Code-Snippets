// 220. Contains Duplicate III
// https://leetcode.com/problems/contains-duplicate-iii
//
// Intuition/Explanation:
// We can use the concept of buckets to group numbers. 
// We divide the numbers into buckets of size `valueDiff + 1`. 
// If two numbers fall into the same bucket, their difference is guaranteed to be at most `valueDiff`.
// If they fall into adjacent buckets, we need to explicitly check if their difference is at most `valueDiff`.
// We maintain a sliding window of size `indexDiff`. If our map has more than `indexDiff` items, 
// we remove the element that just left the window to ensure the index condition `abs(i - j) <= indexDiff`.
//
// Time Complexity: O(N), where N is the number of elements in `nums`. Each element is mapped to a bucket in O(1) time.
// Space Complexity: O(K), where K is `indexDiff`, as we store at most `indexDiff` elements in the dictionary.

class Solution {
    func containsNearbyAlmostDuplicate(_ nums: [Int], _ indexDiff: Int, _ valueDiff: Int) -> Bool {
        if indexDiff <= 0 || valueDiff < 0 || nums.isEmpty {
            return false
        }
        
        var buckets = [Int: Int]()
        let bucketSize = valueDiff + 1
        
        for i in 0..<nums.count {
            let num = nums[i]
            
            // Calculate bucket ID. 
            // Handles negative numbers correctly by shifting them before division.
            let bucketId = num >= 0 ? num / bucketSize : (num - valueDiff) / bucketSize
            
            // Check current bucket
            if buckets[bucketId] != nil {
                return true
            }
            
            // Check adjacent buckets
            if let leftVal = buckets[bucketId - 1], abs(num - leftVal) <= valueDiff {
                return true
            }
            if let rightVal = buckets[bucketId + 1], abs(num - rightVal) <= valueDiff {
                return true
            }
            
            // Add current number to its bucket
            buckets[bucketId] = num
            
            // Maintain window size `indexDiff`
            if i >= indexDiff {
                let numToRemove = nums[i - indexDiff]
                let bucketToRemove = numToRemove >= 0 ? numToRemove / bucketSize : (numToRemove - valueDiff) / bucketSize
                buckets.removeValue(forKey: bucketToRemove)
            }
        }
        
        return false
    }
}
