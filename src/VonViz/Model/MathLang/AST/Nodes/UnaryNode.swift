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

///This node represents a UnaryNode in our AST currenty only minus
struct UnaryNode : SyntaxNode {
    ///Node to minus
    let node : SyntaxNode
    
    ///Take the node and times negative 1 to it
    func eval(_ x: Double, _ y: Double) throws -> Double {
        let evalNode = try node.eval(x,y)
        return -1 * evalNode
    }
    
    func displaySubtree(identAmt: Int) {
        printIdent("UnaryNode[-](", identAmt)
        node.displaySubtree(identAmt: identAmt + 2)
        printIdent(")", identAmt)
    }
}
