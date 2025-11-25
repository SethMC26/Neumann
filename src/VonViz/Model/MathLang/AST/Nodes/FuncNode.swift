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

import Foundation

///This struct represents a math Function in our AST
struct FuncNode : SyntaxNode {
    ///Syntax Node that is inside of our function
    let node: SyntaxNode
    ///Function this node represents
    let function: Token
    
    /// Creates a new Func Node
    /// - Parameters:
    ///   - node: Node that is inside our function
    ///   - function: Function of this node(sin cos or tan)
    init(node: SyntaxNode, function: Token) throws {
        self.node = node
        self.function = function
        
        if ![.SIN, .COS, .TAN].contains(function.type) {
            Log.Lang.fault("Bad type! \(function.type)")
            Log.Lang.debug("We should never get here, this means we have an error in the parser")
            throw ParseError.InvalidNodeCreation
        }
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("FuncNode[\(function)](", identAmt)
        node.displaySubtree(identAmt: identAmt + 2)
        printIdent(")", identAmt)
    }
    
    func eval(_ x: Double, _ y: Double) throws -> Double{
        //get val of node inside our function
        let val = try node.eval(x, y)
        
        //return value from our function
        switch (function.type) {
        case .SIN:
            return sin(val)
        case .COS:
            return cos(val)
        case .TAN:
            return tan(val)
        default:
            Log.Lang.fault("Bad Type! \(function.type) we should NEVER get here")
            self.displaySubtree(identAmt: 0) //display subtree to add debug
            throw ParseError.InvalidNodeCreation
        }
        
    }
}
