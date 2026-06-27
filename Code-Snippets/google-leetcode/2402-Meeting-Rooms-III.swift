// 2402. Meeting Rooms III
// https://leetcode.com/problems/meeting-rooms-iii
//
// Time Complexity: O(M log M + M log N)
//   - Sorting the meetings array takes O(M log M) where M is the number of meetings.
//   - For each meeting, we might push and pop from the heaps. In the worst case, each meeting 
//     takes O(log N) where N is the number of rooms.
//   - Overall time complexity is dominated by these heap operations and sorting.
// Space Complexity: O(N + M)
//   - The availableRooms and occupiedRooms heaps store at most N elements.
//   - The sorted meetings array takes O(M) space.
//   - Overall space complexity is O(N + M).

struct Heap<T> {
    private var elements: [T]
    private let sort: (T, T) -> Bool
    
    init(sort: @escaping (T, T) -> Bool) { 
        self.sort = sort
        self.elements = [] 
    }
    
    var isEmpty: Bool { elements.isEmpty }
    var count: Int { elements.count }
    
    func peek() -> T? { elements.first }
    
    mutating func insert(_ element: T) {
        elements.append(element)
        siftUp(from: elements.count - 1)
    }
    
    mutating func pop() -> T? {
        guard !isEmpty else { return nil }
        elements.swapAt(0, count - 1)
        let element = elements.removeLast()
        if !isEmpty { siftDown(from: 0) }
        return element
    }
    
    private mutating func siftUp(from index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && sort(elements[child], elements[parent]) {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = 2 * parent + 2
            var candidate = parent
            
            if left < count && sort(elements[left], elements[candidate]) { candidate = left }
            if right < count && sort(elements[right], elements[candidate]) { candidate = right }
            if candidate == parent { return }
            
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
}

class Solution {
    
    struct OccupiedRoom {
        let endTime: Int
        let id: Int
    }
    
    func mostBooked(_ n: Int, _ meetings: [[Int]]) -> Int {
        // Sort meetings by their start time
        let sortedMeetings = meetings.sorted { $0[0] < $1[0] }
        
        // Min-heap to keep track of available rooms by their IDs
        var availableRooms = Heap<Int>(sort: <)
        for i in 0..<n {
            availableRooms.insert(i)
        }
        
        // Min-heap to keep track of occupied rooms, sorted by end time, then by room ID
        var occupiedRooms = Heap<OccupiedRoom> { a, b in
            if a.endTime == b.endTime { 
                return a.id < b.id 
            }
            return a.endTime < b.endTime
        }
        
        // Track the number of meetings held in each room
        var meetingCounts = Array(repeating: 0, count: n)
        
        for meeting in sortedMeetings {
            let start = meeting[0]
            let end = meeting[1]
            
            // Release any rooms where the meeting ended before or at the current meeting's start time
            while let earliest = occupiedRooms.peek(), earliest.endTime <= start {
                availableRooms.insert(earliest.id)
                _ = occupiedRooms.pop()
            }
            
            if let roomId = availableRooms.pop() {
                // An available room is found
                occupiedRooms.insert(OccupiedRoom(endTime: end, id: roomId))
                meetingCounts[roomId] += 1
            } else {
                // No available rooms; we must delay the meeting
                // The earliest finishing room will be chosen
                if let earliest = occupiedRooms.pop() {
                    let duration = end - start
                    // The new end time is the room's previous end time + duration of the delayed meeting
                    occupiedRooms.insert(OccupiedRoom(endTime: earliest.endTime + duration, id: earliest.id))
                    meetingCounts[earliest.id] += 1
                }
            }
        }
        
        // Find the room that held the most meetings
        var maxMeetings = -1
        var bestRoom = -1
        
        for i in 0..<n {
            if meetingCounts[i] > maxMeetings {
                maxMeetings = meetingCounts[i]
                bestRoom = i
            }
        }
        
        return bestRoom
    }
}
