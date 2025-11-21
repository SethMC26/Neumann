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

///Syntax Node class takes heavy inspiration from Zachary Kissel's class Programming Languages CSC3120

///Interface of all Syntax nodes in our AST
protocol SyntaxNode {
    /// Display the subtree of our syntaxNode
    /// - Parameter identAmt: Amount of indentation for the subtree
    func displaySubtree(identAmt: Int)
    /// Evaluate this node of the subtree.
    /// F(x, z) = y where x and z are the inputs and y is the point at this syntax node
    /// - Parameters:
    ///   - x: x value to sample
    ///   - z: z value to sample
    /// - Returns: y or result of this syntax node
    func eval(_ x: Double,_ y: Double) throws -> Double
}

extension SyntaxNode {
    /// Prints idented message
    /// - Parameters:
    ///   - msg: Message to print
    ///   - identAmt: Amount to ident message
    func printIdent(_ msg: String,_ identAmt: Int) {
        let indent = String(repeating: " ", count: identAmt)
        print("\(indent)\(msg)")
    }
}
