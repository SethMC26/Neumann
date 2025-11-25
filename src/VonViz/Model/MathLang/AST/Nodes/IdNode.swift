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

///This Node represents an IdNode in our AST either x or z
struct IdNode : SyntaxNode {
    ///Our ID Token
    let ID : Token
    
    /// Creates a new ID token
    /// - Parameter ID: Token of either .X or .Z type
    init(ID: Token) throws{
        self.ID = ID
        
        if ![.X, .Y].contains(ID.type) {
            Log.Lang.fault("Bad type! \(ID.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func eval(_ x: Double, _ y: Double) throws -> Double {
        switch (ID.type) {
        case .X:
            return x
        case .Y:
            return y
        default:
            Log.Lang.fault("Bad Type! \(ID.type) we should NEVER get here")
            self.displaySubtree(identAmt: 0) //display subtree to add debug
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("IdNode[\(ID.val)]", identAmt)
    }
}
