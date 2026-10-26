//
//  find-the-celebrity.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 22/10/26.
//

/*
 Approach:
 The problem can be solved efficiently in two passes using logical deduction.
 
 1. Finding a candidate:
    We start by assuming person 0 is the potential celebrity candidate. We iterate through the rest of the people (from 1 to n - 1).
    For each person `i`, we check if the current `candidate` knows `i` using the `knows(candidate, i)` API.
    - If `candidate` knows `i`, the current `candidate` cannot be the celebrity (because a celebrity knows no one). Thus, person `i` becomes our new candidate.
    - If `candidate` does not know `i`, person `i` cannot be the celebrity (because everyone must know the celebrity). The `candidate` remains unchanged.
    By the end of this linear scan, we eliminate n - 1 people, leaving us with exactly one candidate.
 
 2. Verifying the candidate:
    The first pass only guarantees that if a celebrity exists, it must be this `candidate`. However, there's a chance no celebrity exists at all.
    We iterate through all `n` people one more time to verify:
    - The `candidate` does not know person `i`.
    - Person `i` knows the `candidate`.
    If either of these conditions fails for any person `i` (where i != candidate), we return -1. If the candidate passes all checks, they are the celebrity.

 Time Complexity:
 O(N) - where N is the number of people at the party. We make one pass to find the candidate (N-1 calls to `knows`) and a second pass to verify (up to 2N calls). The total number of API calls is at most 3N, giving a linear time complexity.
 
 Space Complexity:
 O(1) - We only use a single integer variable (`candidate`) to store our current prospective celebrity, which takes constant extra memory.
*/

/**
 * The knows API is defined in the parent class Relation.
 *     func knows(_ a: Int, _ b: Int) -> Bool;
 */

class Solution : Relation {
    func findCelebrity(_ n: Int) -> Int {
        var candidate = 0
        
        // Step 1: Find a potential celebrity candidate
        for i in 1..<n {
            if knows(candidate, i) {
                // If candidate knows i, the candidate cannot be a celebrity.
                // However, i could be, so we update the candidate to i.
                candidate = i
            }
        }
        
        // Step 2: Verify the candidate
        for i in 0..<n {
            if i == candidate {
                continue
            }
            
            // A celebrity should not know anyone, and everyone else should know the celebrity.
            if knows(candidate, i) || !knows(i, candidate) {
                return -1
            }
        }
        
        return candidate
    }
}
