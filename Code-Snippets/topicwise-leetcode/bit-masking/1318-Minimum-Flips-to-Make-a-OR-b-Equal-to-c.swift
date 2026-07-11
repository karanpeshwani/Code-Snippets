// 1318. Minimum Flips to Make a OR b Equal to c
// https://leetcode.com/problems/minimum-flips-to-make-a-or-b-equal-to-c/

/*
 Intuition:
 We can determine the required flips by looking at the numbers bit by bit.
 Let's consider the i-th bit of a, b, and c: `bitA`, `bitB`, and `bitC`.
 There are two main cases depending on the value of `bitC`:
 1. `bitC == 1`: We need `bitA | bitB` to be 1. This means at least one of them must be 1.
    If both `bitA` and `bitB` are 0, we need exactly 1 flip (change either `bitA` or `bitB` to 1).
 2. `bitC == 0`: We need `bitA | bitB` to be 0. This means both must be 0.
    If `bitA` is 1, it requires 1 flip. If `bitB` is 1, it requires 1 flip. 
    So the number of flips is simply `bitA + bitB`.
 We iterate through all 32 bits and sum the flips required for each position.

 Time Complexity: O(1)
 - We always check 32 bits, which is a constant number of operations.
 - Therefore, the time complexity is O(1) (or O(log(max(a, b, c))) if viewed proportionally).

 Space Complexity: O(1)
 - We only use a few variables to store the bit values and the total flips.
 - Overall space complexity is O(1).
 */

class Solution {
    func minFlips(_ a: Int, _ b: Int, _ c: Int) -> Int {
        var flips = 0
        
        for i in 0..<32 {
            let bitA = (a >> i) & 1
            let bitB = (b >> i) & 1
            let bitC = (c >> i) & 1
            
            if (bitA | bitB) != bitC {
                if bitC == 1 {
                    // We need at least one 1, both are 0, so flip one of them
                    flips += 1
                } else {
                    // We need both to be 0, flip any that are 1
                    flips += bitA + bitB
                }
            }
        }
        
        return flips
    }
}
