// 2092-Find-All-People-With-Secret.swift
// 2092. Find All People With Secret
// https://leetcode.com/problems/find-all-people-with-secret/
//
// Time Complexity: O(M log M + M) where M is the number of meetings. Sorting takes M log M, and Union-Find operations take almost O(1) time per meeting.
// Space Complexity: O(N + M) for the Union-Find parent array and temporary meeting groups.

class Solution {
    func findAllPeople(_ n: Int, _ meetings: [[Int]], _ firstPerson: Int) -> [Int] {
        var parent = Array(0..<n)
        
        func find(_ i: Int) -> Int {
            if parent[i] == i { return i }
            parent[i] = find(parent[i])
            return parent[i]
        }
        
        func union(_ i: Int, _ j: Int) {
            let root1 = find(i)
            let root2 = find(j)
            if root1 != root2 {
                // Ensure the person who knows the secret (root 0) is the ultimate root
                if root1 == find(0) {
                    parent[root2] = root1
                } else if root2 == find(0) {
                    parent[root1] = root2
                } else {
                    parent[root1] = root2
                }
            }
        }
        
        func connectedTo0(_ i: Int) -> Bool {
            return find(i) == find(0)
        }
        
        union(0, firstPerson)
        
        var sortedMeetings = meetings.sorted { $0[2] < $1[2] }
        var i = 0
        let m = sortedMeetings.count
        
        while i < m {
            let currentTime = sortedMeetings[i][2]
            var j = i
            var currentMeetings = [[Int]]()
            var peopleInMeetings = Set<Int>()
            
            while j < m && sortedMeetings[j][2] == currentTime {
                currentMeetings.append(sortedMeetings[j])
                peopleInMeetings.insert(sortedMeetings[j][0])
                peopleInMeetings.insert(sortedMeetings[j][1])
                j += 1
            }
            
            for meeting in currentMeetings {
                union(meeting[0], meeting[1])
            }
            
            // Revert changes for people who didn't get connected to 0
            for person in peopleInMeetings {
                if !connectedTo0(person) {
                    parent[person] = person
                }
            }
            
            i = j
        }
        
        var res = [Int]()
        for i in 0..<n {
            if connectedTo0(i) {
                res.append(i)
            }
        }
        return res
    }
}
