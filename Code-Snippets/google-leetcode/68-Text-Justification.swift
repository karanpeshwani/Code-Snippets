// 68. Text Justification
// https://leetcode.com/problems/text-justification
//
// Time Complexity: O(N), where N is the total number of characters in all words. We process each word and character to pack them into lines and then justify each line.
// Space Complexity: O(N), for storing the justified lines in the result array. A single line stores at most O(maxWidth) characters, and we store the result.

class Solution {
    func fullJustify(_ words: [String], _ maxWidth: Int) -> [String] {
        var res = [String]()
        var line = [String]()
        var lineLength = 0
        
        for word in words {
            // Check if adding the new word would exceed the max width
            // lineLength: length of words currently in the line
            // line.count: minimum spaces needed between words
            // word.count: length of the new word
            if lineLength + line.count + word.count > maxWidth {
                // Justify the current line and add to result
                var extraSpaces = maxWidth - lineLength
                
                // If there's only one word, it's left justified
                if line.count == 1 {
                    res.append(line[0] + String(repeating: " ", count: extraSpaces))
                } else {
                    // Distribute spaces evenly between words
                    let spacesBetweenWords = extraSpaces / (line.count - 1)
                    var extraSpacesLeft = extraSpaces % (line.count - 1)
                    
                    var justifiedLine = ""
                    for i in 0..<(line.count - 1) {
                        justifiedLine += line[i]
                        justifiedLine += String(repeating: " ", count: spacesBetweenWords)
                        if extraSpacesLeft > 0 {
                            justifiedLine += " "
                            extraSpacesLeft -= 1
                        }
                    }
                    // Add the last word of the line
                    justifiedLine += line.last!
                    res.append(justifiedLine)
                }
                
                // Start a new line with the current word
                line.removeAll()
                lineLength = 0
            }
            
            line.append(word)
            lineLength += word.count
        }
        
        // Handle the last line (must be left justified)
        var lastLine = line.joined(separator: " ")
        lastLine += String(repeating: " ", count: maxWidth - lastLine.count)
        res.append(lastLine)
        
        return res
    }
}
