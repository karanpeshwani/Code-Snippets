// 1610. Maximum Number of Visible Points
// https://leetcode.com/problems/maximum-number-of-visible-points/

/*
 Intuition:
 The problem asks for the maximum number of points we can see from a given location, looking within a given viewing angle.
 We can calculate the angle of each point relative to our location using `atan2(y, x)`.
 We convert these angles to degrees (or keep in radians). To handle the wrap-around (e.g., viewing from 350 degrees to 10 degrees),
 we can duplicate all the sorted angles by adding 360 degrees to them and appending them to the array.
 Then, we can use a sliding window approach: for each `left` angle, we expand `right` as long as `angles[right] - angles[left] <= angle`.
 Note that points sitting exactly on our location are always visible regardless of the viewing direction. We count them separately.

 Time Complexity: O(N log N)
 - N is the number of points.
 - Calculating angles takes O(N).
 - Sorting the angles takes O(N log N).
 - The sliding window takes O(N) as both `left` and `right` traverse the array at most once.
 - Overall time complexity is O(N log N).

 Space Complexity: O(N)
 - We store the angles of all points, which takes O(N) space.
 - Duplicating the array takes an additional O(N) space.
 - Overall space complexity is O(N).
 */

import Foundation

class Solution {
    func visiblePoints(_ points: [[Int]], _ angle: Int, _ location: [Int]) -> Int {
        var angles = [Double]()
        var sameLocationCount = 0
        
        for point in points {
            let dx = point[0] - location[0]
            let dy = point[1] - location[1]
            
            if dx == 0 && dy == 0 {
                sameLocationCount += 1
            } else {
                let atan = atan2(Double(dy), Double(dx))
                // Convert to degrees
                let degree = atan * 180.0 / Double.pi
                angles.append(degree)
            }
        }
        
        angles.sort()
        
        let n = angles.count
        for i in 0..<n {
            angles.append(angles[i] + 360.0)
        }
        
        var maxVisible = 0
        var left = 0
        let angleDouble = Double(angle)
        
        for right in 0..<angles.count {
            while angles[right] - angles[left] > angleDouble {
                left += 1
            }
            maxVisible = max(maxVisible, right - left + 1)
        }
        
        return maxVisible + sameLocationCount
    }
}
