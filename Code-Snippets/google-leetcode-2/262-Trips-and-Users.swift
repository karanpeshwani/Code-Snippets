// 262. Trips and Users
// https://leetcode.com/problems/trips-and-users
//
// Intuition/Explanation:
// This is natively an SQL Database problem on LeetCode. 
// The goal is to find the cancellation rate of unbanned users (both client and driver) each day 
// between '2013-10-01' and '2013-10-03'.
// 
// The optimal SQL Query is:
// ```sql
// SELECT Request_at AS Day,
//        ROUND(SUM(IF(Status != 'completed', 1, 0)) / COUNT(*), 2) AS 'Cancellation Rate'
// FROM Trips t
// JOIN Users c ON t.Client_Id = c.Users_Id AND c.Banned = 'No'
// JOIN Users d ON t.Driver_Id = d.Users_Id AND d.Banned = 'No'
// WHERE Request_at BETWEEN '2013-10-01' AND '2013-10-03'
// GROUP BY Request_at
// ```
// 
// For completeness in Swift, below is an algorithmic simulation representing the same logic using structs.
// We iterate through the trips, verify that both the client and driver are unbanned using the users dictionary, 
// and aggregate the total and cancelled trips by date. Finally, we calculate the rounded rate.
//
// Time Complexity: O(T + U), where T is number of trips and U is number of users.
// Space Complexity: O(U + D), where U is number of users and D is unique days.

struct Trip {
    let id: Int
    let clientId: Int
    let driverId: Int
    let cityId: Int
    let status: String
    let requestAt: String
}

struct User {
    let usersId: Int
    let banned: String
    let role: String
}

class Solution {
    func cancellationRate(trips: [Trip], users: [User]) -> [String: Double] {
        var userBannedStatus = [Int: Bool]()
        for user in users {
            userBannedStatus[user.usersId] = (user.banned == "Yes")
        }
        
        var totalTripsByDay = [String: Int]()
        var cancelledTripsByDay = [String: Int]()
        
        for trip in trips {
            // Check date range
            if trip.requestAt >= "2013-10-01" && trip.requestAt <= "2013-10-03" {
                let clientBanned = userBannedStatus[trip.clientId] ?? true
                let driverBanned = userBannedStatus[trip.driverId] ?? true
                
                // Both must be unbanned
                if !clientBanned && !driverBanned {
                    totalTripsByDay[trip.requestAt, default: 0] += 1
                    
                    if trip.status != "completed" {
                        cancelledTripsByDay[trip.requestAt, default: 0] += 1
                    }
                }
            }
        }
        
        var result = [String: Double]()
        for (day, total) in totalTripsByDay {
            let cancelled = cancelledTripsByDay[day] ?? 0
            let rate = Double(cancelled) / Double(total)
            // Round to 2 decimal places
            result[day] = round(rate * 100) / 100.0
        }
        
        return result
    }
}
