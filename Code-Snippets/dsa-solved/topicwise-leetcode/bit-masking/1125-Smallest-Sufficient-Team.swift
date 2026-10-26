// 1125. Smallest Sufficient Team
// https://leetcode.com/problems/smallest-sufficient-team/

/*
 Intuition:
 We need to find the smallest set of people (a team) that collectively possess all the required skills.
 The number of required skills is very small (<= 16), which strongly suggests using a bitmask.
 Each skill is mapped to an index, and a person's skill set is represented as an integer bitmask.
 We can use Dynamic Programming (DP). `dp[mask]` will store the indices of the smallest team 
 that possesses the skills represented by `mask`.
 We initialize `dp[0]` as an empty array, and process each person one by one.
 For a given person with `personMask`, we iterate over all currently reachable states `mask` in our DP.
 We can form a new state `newMask = mask | personMask`. If `newMask` hasn't been reached yet, 
 or if the new team (`dp[mask]` + this person) is strictly smaller than the team currently at `dp[newMask]`,
 we update `dp[newMask]`.

 Time Complexity: O(P * 2^N)
 - Let P be the number of people and N be the number of required skills.
 - For each of the P people, we might iterate over up to 2^N states.
 - Total time complexity is O(P * 2^N).

 Space Complexity: O(2^N * P)
 - We use a dictionary/array for DP states where there are up to 2^N states.
 - In the worst case, each state could store a team array of size up to P.
 - Overall space complexity is O(P * 2^N).
 */

class Solution {
    func smallestSufficientTeam(_ req_skills: [String], _ people: [[String]]) -> [Int] {
        let n = req_skills.count
        var skillMap = [String: Int]()
        
        // Map each skill to a specific bit index
        for (i, skill) in req_skills.enumerated() {
            skillMap[skill] = i
        }
        
        var dp = [Int: [Int]]()
        dp[0] = []
        
        for (personIndex, personSkills) in people.enumerated() {
            var personMask = 0
            for skill in personSkills {
                if let bitIndex = skillMap[skill] {
                    personMask |= (1 << bitIndex)
                }
            }
            
            // If the person has no useful skills, skip them
            if personMask == 0 { continue }
            
            // We must iterate over a snapshot of the current DP states
            // to avoid modifying the dictionary while iterating.
            let currentStates = dp
            
            for (mask, team) in currentStates {
                let newMask = mask | personMask
                
                // Update if newMask is not visited OR we found a strictly smaller team
                if dp[newMask] == nil || team.count + 1 < dp[newMask]!.count {
                    var newTeam = team
                    newTeam.append(personIndex)
                    dp[newMask] = newTeam
                }
            }
        }
        
        let targetMask = (1 << n) - 1
        return dp[targetMask] ?? []
    }
}
