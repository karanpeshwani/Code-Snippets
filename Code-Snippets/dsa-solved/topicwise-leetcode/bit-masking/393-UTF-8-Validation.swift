// 393. UTF-8 Validation
// https://leetcode.com/problems/utf-8-validation/

/*
 Intuition:
 A valid UTF-8 character can be 1 to 4 bytes long. The number of bytes is determined by the first byte:
 - 1 byte: 0xxxxxxx
 - 2 bytes: 110xxxxx 10xxxxxx
 - 3 bytes: 1110xxxx 10xxxxxx 10xxxxxx
 - 4 bytes: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 We can process the array byte by byte. If we are starting a new character, we count the number of leading 1s
 to determine the character's length. If the length is 1 (starts with 0), we continue. If it's 2, 3, or 4, 
 we expect the next (length - 1) bytes to start with '10' (which means the two most significant bits are 1 and 0).
 We maintain a `remainingBytes` counter to track how many '10xxxxxx' bytes we still need to validate.

 Time Complexity: O(N)
 - We iterate through the given array of size N exactly once.
 - Each byte is processed in O(1) time using bitwise operations.
 - Total time complexity is O(N).

 Space Complexity: O(1)
 - We only use a few integer variables (`remainingBytes`, bitmasks) for state tracking.
 - Overall space complexity is O(1).
 */

class Solution {
    func validUtf8(_ data: [Int]) -> Bool {
        var remainingBytes = 0
        
        // Bitmasks to extract the leading bits
        let mask1 = 1 << 7 // 10000000
        let mask2 = 1 << 6 // 01000000
        
        for num in data {
            // Get only the least significant 8 bits
            let byte = num & 0xFF
            
            if remainingBytes == 0 {
                // Determine the length of the new UTF-8 character
                var mask = 1 << 7
                while (byte & mask) != 0 {
                    remainingBytes += 1
                    mask >>= 1
                }
                
                // 1 byte characters have 0 leading 1s (remainingBytes == 0)
                if remainingBytes == 0 {
                    continue
                }
                
                // UTF-8 characters can only be 1 to 4 bytes long.
                // Also, a 1-byte character does not start with '10'.
                if remainingBytes == 1 || remainingBytes > 4 {
                    return false
                }
                
                // We have already processed the first byte, so we need remainingBytes - 1 more
                remainingBytes -= 1
            } else {
                // If it's a continuation byte, it must start with '10'
                if (byte & mask1) == 0 || (byte & mask2) != 0 {
                    return false
                }
                remainingBytes -= 1
            }
        }
        
        // If remainingBytes is 0, all characters were fully validated
        return remainingBytes == 0
    }
}
