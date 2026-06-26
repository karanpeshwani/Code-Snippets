// 1944. Number of Visible People in a Queue
// https://leetcode.com/problems/number-of-visible-people-in-a-queue/
//
// Time Complexity: O(N), where N is the number of people in the queue. 
// We iterate through the array once from right to left. Each person's height is pushed 
// and popped from the monotonic stack at most once, making the overall time complexity linear.
// Space Complexity: O(N) in the worst case (e.g., if heights are sorted in descending order) 
// to store the heights in the monotonic stack.

class Solution {
    func canSeePersonsCount(_ heights: [Int]) -> [Int] {
        let n = heights.count
        var result = Array(repeating: 0, count: n)
        
        // Monotonic decreasing stack storing heights of people.
        // It helps keep track of the potential people that can be seen by someone to their left.
        var stack = [Int]() 
        
        // Traverse from right to left to evaluate what person 'i' can see to their right
        for i in stride(from: n - 1, through: 0, by: -1) {
            var visibleCount = 0
            let currentHeight = heights[i]
            
            // Pop people who are shorter than the current person.
            // The current person can see all of them, and since they are shorter,
            // they will be blocked by the current person for anyone further left.
            while !stack.isEmpty && stack.last! < currentHeight {
                stack.removeLast()
                visibleCount += 1
            }
            
            // If the stack is not empty, the next person in the stack is taller than the current person.
            // The current person can see them, but this taller person blocks the view of anyone else behind them.
            if !stack.isEmpty {
                visibleCount += 1
            }
            
            result[i] = visibleCount
            // Add current person to the stack as they might be visible to people on their left
            stack.append(currentHeight)
        }
        
        return result
    }
}
