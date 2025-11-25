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

struct SyntaxTree {
    let nodes: [ SyntaxNode ]
    
    init(nodes: [SyntaxNode]) {
        self.nodes = nodes
    }
    
    func displaytree() {
        print("AST(")
        for node in nodes {
            node.displaySubtree(identAmt: 1)
        }
        print(")")
    }

    func eval(_ x: Double, _ y: Double) throws -> Double {
        var num: Double = 0.0
        for node in nodes {
            num += try node.eval(x, y)
        }
        return num
    }

}
