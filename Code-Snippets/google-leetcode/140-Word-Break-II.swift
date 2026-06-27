// 140. Word Break II
// https://leetcode.com/problems/word-break-ii/
//
// Time Complexity: O(N * 2^N), where N is the length of the string `s`. In the worst case (e.g., s = "aaaaa", wordDict = ["a", "aa", "aaa", ...]), the number of possible sentences can be 2^(N-1). We memoize the results to avoid redundant work, but generating all valid combinations still takes exponential time in the worst case.
// Space Complexity: O(N * 2^N) to store the memoization dictionary containing all valid sentences for each start index. The recursion call stack depth can also go up to O(N).

class Solution {
    func wordBreak(_ s: String, _ wordDict: [String]) -> [String] {
        let wordSet = Set(wordDict)
        let sArray = Array(s)
        var memo: [Int: [String]] = [:]
        
        func dfs(_ start: Int) -> [String] {
            // Return cached result if already computed for this start index
            if let cached = memo[start] {
                return cached
            }
            
            // Base case: we've reached the end of the string, return an empty string to represent a valid path
            if start == sArray.count {
                return [""]
            }
            
            var result: [String] = []
            
            // Try all possible end indices for the next word
            for end in start + 1...sArray.count {
                let prefix = String(sArray[start..<end])
                
                // If prefix is a valid dictionary word, recursively find all combinations for the suffix
                if wordSet.contains(prefix) {
                    let suffixWays = dfs(end)
                    
                    for way in suffixWays {
                        if way.isEmpty {
                            // If suffix is empty (meaning prefix is the last word), just append prefix
                            result.append(prefix)
                        } else {
                            // Otherwise, concatenate prefix with space and the suffix combination
                            result.append(prefix + " " + way)
                        }
                    }
                }
            }
            
            // Memoize the result for the current start index before returning
            memo[start] = result
            return result
        }
        
        return dfs(0)
    }
}
