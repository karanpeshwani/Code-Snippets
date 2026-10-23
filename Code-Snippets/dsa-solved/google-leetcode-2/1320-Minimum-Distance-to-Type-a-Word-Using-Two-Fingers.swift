// 1320. Minimum Distance to Type a Word Using Two Fingers
// https://leetcode.com/problems/minimum-distance-to-type-a-word-using-two-fingers

/*
 Intuition:
 We need to type a word using two fingers on a 2D keyboard, minimizing the total movement distance.
 This can be modeled with Dynamic Programming.
 A naive state would be `dp(index, finger1, finger2)`, representing the min distance to type the string
 from `index` to the end, given the positions of the two fingers.
 However, we can optimize this. When typing the character at `index`, one of the fingers MUST have just
 typed the character at `index - 1` (or we are at the very first character).
 Therefore, the state can be reduced to `dp(index, other_finger)`.
 Let `dp[other_finger]` be the minimum distance to type the prefix up to the current character,
 where one finger is at the current character, and the other is at `other_finger`.
 For the next character `c`, we can either:
 1. Move the finger currently at the previous character to `c`. The other finger stays at `other_finger`.
 2. Move the `other_finger` to `c`. The finger at the previous character becomes the new `other_finger`.

 Time Complexity: O(N)
 - The length of the word is N (up to 300).
 - At each step, we iterate over 27 possible states for `other_finger` (26 letters + 1 unplaced).
 - Transition calculation takes O(1).
 - Overall time complexity is O(N * 27) = O(N).

 Space Complexity: O(1)
 - We only need the DP array from the previous step.
 - The DP array size is constant (27 states).
 - Overall space complexity is O(1).
 */

class Solution {
    func minimumDistance(_ word: String) -> Int {
        let chars = Array(word)
        let n = chars.count
        if n <= 2 { return 0 }
        
        // Calculate distance between two characters ('A' to 'Z') on the 6-col keyboard
        // 26 represents an unplaced finger
        func getDist(_ a: Int, _ b: Int) -> Int {
            if a == 26 || b == 26 { return 0 }
            let r1 = a / 6, c1 = a % 6
            let r2 = b / 6, c2 = b % 6
            return abs(r1 - r2) + abs(c1 - c2)
        }
        
        // dp[other_finger] stores min distance for prefix
        // Initialize with a large value
        var dp = Array(repeating: 100000, count: 27)
        
        // Base case: after typing the first character
        let firstCharIdx = Int(chars[0].asciiValue! - Character("A").asciiValue!)
        dp[26] = 0 // The other finger is unplaced
        
        var prevCharIdx = firstCharIdx
        
        for i in 1..<n {
            let currCharIdx = Int(chars[i].asciiValue! - Character("A").asciiValue!)
            var nextDp = Array(repeating: 100000, count: 27)
            
            for otherFinger in 0...26 {
                if dp[otherFinger] == 100000 { continue }
                
                // Option 1: Move the finger that typed prevCharIdx to currCharIdx
                // The other finger remains at otherFinger
                let dist1 = getDist(prevCharIdx, currCharIdx)
                nextDp[otherFinger] = min(nextDp[otherFinger], dp[otherFinger] + dist1)
                
                // Option 2: Move the otherFinger to currCharIdx
                // The finger that typed prevCharIdx becomes the new otherFinger
                let dist2 = getDist(otherFinger, currCharIdx)
                nextDp[prevCharIdx] = min(nextDp[prevCharIdx], dp[otherFinger] + dist2)
            }
            
            dp = nextDp
            prevCharIdx = currCharIdx
        }
        
        return dp.min() ?? 0
    }
}
