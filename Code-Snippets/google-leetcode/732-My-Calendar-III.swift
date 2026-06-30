//Again -> Segment Tree
// 732. My Calendar III
// Link: https://leetcode.com/problems/my-calendar-iii/
//
// Time Complexity: O(N^2), where N is the number of events booked.
// Explanation: For each new event, we iterate over all existing boundaries to calculate the maximum overlaps. Extracting keys and sorting them takes O(N log N) per booking, making overall O(N^2 log N).
// Space Complexity: O(N)
// Explanation: We store the start and end times of at most N events, leading to a maximum of 2N points in the timeline map.

class MyCalendarThree {
    // Stores the delta for each time point.
    // +1 for start, -1 for end
    private var timeline = [Int: Int]()
    
    init() {}
    
    func book(_ startTime: Int, _ endTime: Int) -> Int {
        timeline[startTime, default: 0] += 1
        timeline[endTime, default: 0] -= 1
        
        var ongoing = 0
        var maxK = 0
        
        // Swift Dictionary is unordered, so we must sort the keys to process chronologically
        let sortedTimes = timeline.keys.sorted()
        
        for time in sortedTimes {
            ongoing += timeline[time]!
            maxK = max(maxK, ongoing)
        }
        
        return maxK
    }
}
