/*
 *   Copyright (C) 2025  Seth Holtzman
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

///Lexer for MathLang
class Lexer {
    ///character stream feeding lexer
    private let charStream: CharStream
    
    /// Create a new Lexer
    /// - Parameter input: Input to lexer to Tokenize
    init(input: String) {
        charStream = CharStream(characters: input)
    }
    
    /// Get next Token in stream from Lexer
    /// - Returns: Token from Lexer
    func nextToken() -> Token {
        var nextChar = charStream.read()
        
        switch nextChar.type {
        case .EOF:
            return Token(type: .EOF, val: "\0")
        case .DIGIT:
            var number: String = String(nextChar.value)
            
            //attempt to read more digit of our number
            nextChar = charStream.read()
            while(nextChar.type == .DIGIT ) {
                //append digit to string
                number.append(nextChar.value)
                nextChar = charStream.read()
            }
            
            //since this is a double we may see a dot if so loop again
            if (nextChar.type == .DOT) {
                number.append(nextChar.value)
                nextChar = charStream.read()
                while(nextChar.type == .DIGIT) {
                    //append digit to string
                    number.append(nextChar.value)
                    nextChar = charStream.read()
                }
            }
            
            //in either case we have now gone too far in the stream(past the digit) and need to unread
            charStream.unread()
            
            return Token(type: .NUMBER, val: number)
        case .TEXT:
            switch nextChar.value {
            //handle x and y
            case "x":
                return Token(type: .X, val: "x")
            case "y":
                return Token(type: .Y, val: "y")
            //handle math keyword
            default:
                var keyword = String(nextChar.value)
                //build keyword
                nextChar = charStream.read()
                while(nextChar.type == .TEXT) {
                    //append next char
                    keyword.append(nextChar.value)
                    nextChar = charStream.read()
                }
                //we have gone too far and must unread
                charStream.unread()
                
                return lookup(keyword)
            }
        case .OTHER:
            switch nextChar.value {
                //handle operator cases
            case "+":
                return Token(type: .ADD, val: "+")
            case "-":
                return Token(type: .SUB, val: "-")
            case "*":
                //could be multiplication or exponent lets check
                nextChar = charStream.read()
                if (nextChar.value == "*"){
                    return Token(type: .EXP,val: "**")
                }
                else {
                    //we have gone too far and must unread
                    charStream.unread()
                    return Token(type: .MULT, val: "*")
                }
            case "/":
                //could be division or rooting lets check
                nextChar = charStream.read()
                if (nextChar.value == "/") {
                    return Token(type: .ROOT, val: "//")
                }
                else {
                    //we have gone too far and must unread
                    charStream.unread()
                    return Token(type: .DIV, val: "/")
                }
                //handle params
            case "(":
                return Token(type: .LPAREN, val: "(")
            case ")":
                return Token(type: .RPAREN, val: ")")
            default:
                return Token(type: .UNKNOWN, val: String(nextChar.value))
            }
        default:
            return Token(type: .UNKNOWN, val: String(nextChar.value))
        }
        
    }
    
    /// Looks up a math function
    /// - Parameter keyword: Keyword to check
    /// - Returns: Token if valid else Unknown token
    private func lookup(_ keyword: String) -> Token {
        switch keyword {
        case "sin":
            return Token(type: .SIN, val: "sin")
        case "cos":
            return Token(type: .COS, val: "cos")
        case "tan":
            return Token(type: .TAN, val: "tan")
        default:
            return Token(type: .UNKNOWN, val: keyword)
        }
        
    }
}

/// Token with type TokenType and val String of that token
struct Token : CustomStringConvertible{
    let type: TokenType
    let val: String;
    
    var description: String {
        "Token(type: \(type), val: \(val))"
    }
}

/// Type of token
enum TokenType {
    case ADD
    case SUB
    case MULT
    case DIV
    case EXP
    case ROOT
    case SIN
    case COS
    case TAN
    case LPAREN
    case RPAREN
    case X
    case Y
    case NUMBER
    case EOF
    case UNKNOWN
}
