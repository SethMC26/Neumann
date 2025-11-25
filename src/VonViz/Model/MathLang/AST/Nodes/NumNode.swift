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

///This class represents a number literal in our program 
struct NumNode : SyntaxNode {
    let num: Double
    
    /// Creates a new Num Node
    /// - Parameter token: Number Token(must have type `.NUMBER`) to create
    init(token: Token) throws{
        //check token type
        if token.type != .NUMBER {
            Log.Lang.fault("Bad type! \(token.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
        
        //assign temp value to safely unwrap(its a swift thing)
        guard let _num = Double(token.val) else {
            Log.Lang.fault("Could not cast token val: \(token.val) to Double")
            throw ParseError.InvalidNodeCreation
        }
        
        num = _num
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("IdNode[\(String(num))", identAmt)
    }
    
    func eval(_ x: Double, _ y: Double) -> Double {
        return num
    }
}
