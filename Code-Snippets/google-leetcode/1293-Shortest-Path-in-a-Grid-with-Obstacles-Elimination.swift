//Again => Revision
// 1293. Shortest Path in a Grid with Obstacles Elimination
// https://leetcode.com/problems/shortest-path-in-a-grid-with-obstacles-elimination/
// 
// Time Complexity: O(m * n * k), where m is the number of rows, n is the number of columns, 
// and k is the number of obstacles we can eliminate. In the worst-case scenario, we might 
// visit every cell for every possible number of obstacles eliminated.
// Space Complexity: O(m * n * k) to store the visited states and the queue for BFS.

import Collections

class Solution {

    private var n: Int = 0
    private var m: Int = 0
    private var visited: [[Int]] = []   //k remaining
    private var dx: [Int] = [1,-1,0,0]
    private var dy: [Int] = [0,0,1,-1]

    private func isCellValid(_ x: Int, _ y: Int) -> Bool { x >= 0 && x < n && y >= 0 && y < m }

    func shortestPath(_ grid: [[Int]], _ k: Int) -> Int {
        self.n = grid.count
        self.m = grid[0].count
        self.visited = Array(repeating: Array(repeating: -1, count: m), count: n)

        var q: Deque<[Int]> = Deque()   //Deque of [i, j, kRemaining, steps]

        q.append([0,0,k,0])
        visited[0][0] = k

        while !q.isEmpty {

            let top = q.removeFirst()
            let x = top[0]
            let y = top[1]
            let kRemaining = top[2]
            let steps = top[3]

            if x == n - 1 && y == m - 1 {
                return steps
            }

            for i in 0..<4 {
                let xNew = x + dx[i]
                let yNew = y + dy[i]

                if isCellValid(xNew, yNew) {

                    let kRemainingNew = grid[xNew][yNew] == 1 ? kRemaining - 1 : kRemaining

                    if visited[xNew][yNew] < kRemainingNew {
                        visited[xNew][yNew] = kRemainingNew
                        q.append([xNew, yNew, kRemainingNew, steps + 1])
                    }
                }
            }
        }

        return -1
    }
}
