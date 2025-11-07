/// Character Stream for MathLang
class CharStream {
    /// Characters in this stream
    private let characters: String
    /// Current index of the stream
    private var currCharIndex: String.Index
    ///Keep track of if last read aws EOF
    private var lastReadWasEOF = false
    
    /// Create new Character Stream
    /// - Parameter characters: String to create the stream from(values will be lowercased automatically)
    init(characters: String) {
        //make case insensity treat everything lowercase
        self.characters = characters.lowercased()
        self.currCharIndex = self.characters.startIndex
    }
    
    /// Reads the next value in the stream
    /// - Returns: Tuple with the type of next character(CharType) and value of that character(Character)
    func read() -> (type: CharType, value: Character) {
        //skip whitespace
        while currCharIndex < characters.endIndex && getCharType() == .WHITESPACE {
            //increment char index
            currCharIndex = characters.index(after: currCharIndex)
        }
        
        //check if we are at end of the string
        if currCharIndex >= characters.endIndex {
            currCharIndex = characters.endIndex
            lastReadWasEOF = true
            return (.EOF, "\0")
        }
        
        //save value before incrementing stream
        let charTuple = (getCharType(), characters[currCharIndex])
        
        //increment for next read
        currCharIndex = characters.index(after: currCharIndex)
        //last Read was not EOF
        lastReadWasEOF = false
        //return current char and char type
        return charTuple
    }
    
    /// Rewinds the stream by 1
    func unread() {
        // If the previous read() returned EOF, we didn't advance; do nothing.
        if lastReadWasEOF { return } 
        
        //check if we are at end of the string
        if currCharIndex <= characters.startIndex {
            Log.Lang.error("CharStream: Tried to unread first character! This is not possible")
            return
        }
        
        //decrement charIndex
        currCharIndex = characters.index(before: currCharIndex)
    }
    
    /// Gets the current char types based off the current char idnex
    /// - Returns: CharType of current value in stream
    private func getCharType() -> CharType {
        let currChar: Character = characters[currCharIndex]
        
        switch true {
        case currChar == ".":
            return CharType.DOT
        case currChar.isNumber:
            return CharType.DIGIT
        case currChar.isWhitespace:
            return CharType.WHITESPACE
        case currChar.isLetter:
            return CharType.TEXT
        default:
            return CharType.OTHER
        }
    }
    
}

/// Type of character in the stream
enum CharType {
    case TEXT
    case DIGIT
    case DOT
    case WHITESPACE
    case EOF
    case OTHER
}
