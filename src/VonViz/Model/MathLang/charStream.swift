class CharStream {
    private let characters: String
    private var currCharIndex: String.Index
    var nextCharType: CharType = CharType.UNKNOWN
    
    init(characters: String) {
        self.characters = characters
        self.currCharIndex = characters.startIndex
    }
    
    func advance() {
        if currCharIndex >= characters.endIndex {
            nextCharType = CharType.EOF
            currCharIndex = characters.endIndex
            return
        }
        
        currCharIndex = characters.index(after: currCharIndex)
        
        repeat {
            nextCharType = getCharType()
        }
        while ( nextCharType == CharType.WHITESPACE )
    }
    
    func unadvance() {
        if currCharIndex <= characters.startIndex {
            Log.Lang.error("CharStream: Tried to unread first character! This is not possible")
            return
        }
        
        currCharIndex = characters.index(before: currCharIndex)
        nextCharType = getCharType()
    }
    
    private func getCharType() -> CharType {
        let currChar: Character = characters[currCharIndex]
        
        switch true {
        case currChar == ".":
            return CharType.DOT
        case currChar.isNumber:
            return CharType.DIGIT
        case currChar.isWhitespace:
            return CharType.WHITESPACE
        case currChar.isASCII:
            return CharType.TEXT
        default:
            return CharType.UNKNOWN
        }
    }
}

enum CharType {
    case TEXT
    case DIGIT
    case DOT
    case WHITESPACE
    case EOF
    case UNKNOWN
}
