// 683. K Empty Slots
// https://leetcode.com/problems/k-empty-slots/

/*
 Intuition:
 We are given the `bulbs` array where `bulbs[i]` represents the position of the bulb turned on at day `i+1`.
 It's easier to think about this in terms of when each bulb at position `p` is turned on.
 Let's create a `days` array where `days[p]` represents the day the bulb at position `p` is turned on.
 We are looking for two bulbs at positions `left` and `right` such that `right - left = k + 1`.
 Furthermore, all bulbs between `left` and `right` must be turned on AFTER both `left` and `right` bulbs.
 This means for all `i` from `left + 1` to `right - 1`, we must have `days[i] > max(days[left], days[right])`.
 We can use a sliding window to find such `left` and `right`.
 We iterate through the `days` array. If we find an invalid bulb in between (i.e., `days[i] < max(days[left], days[right])`),
 we slide our window starting from `i`, because no valid window can contain `i`.

 Time Complexity: O(N)
 - N is the number of bulbs.
 - We create the `days` array in O(N) time.
 - We iterate through the `days` array with our sliding window. The pointer `i` only moves forward, so the inner logic is executed at most N times.
 - Overall time complexity is O(N).

 Space Complexity: O(N)
 - We use an array `days` of size N + 1.
 - Overall space complexity is O(N).
 */

class Solution {
    func kEmptySlots(_ bulbs: [Int], _ k: Int) -> Int {
        let n = bulbs.count
        var days = [Int](repeating: 0, count: n + 1)
        
        // Map bulb position to the day it gets turned on
        for (i, bulb) in bulbs.enumerated() {
            days[bulb] = i + 1
        }
        
        var left = 1
        var right = k + 2
        var minDay = Int.max
        var i = 1
        
        while right <= n {
            if i == right {
                // We successfully found a valid window
                minDay = min(minDay, max(days[left], days[right]))
                left = i
                right = i + k + 1
            } else if days[i] < max(days[left], days[right]) {
                // Invalid bulb found, restart the window from here
                left = i
                right = i + k + 1
            }
            i += 1
        }
        
        return minDay == Int.max ? -1 : minDay
    }
}
