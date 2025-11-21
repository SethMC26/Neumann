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

///Parser to parse an AST for MathLang
class Parser {
    ///Lexer parser will use for token stream
    private let lexer: Lexer
    ///Current token we are handling
    private var currToken: Token
    
    ///Create a new Parser
    /// - Parameter input: <#input description#>
    init(input: String) {
        self.lexer = Lexer(input: input)
        self.currToken = lexer.nextToken()
    }
    
    ///Parse the expression and get Abstract Syntax Tree
    func parse() throws -> SyntaxTree {
        var nodes: [ SyntaxNode ] = []
        
        while(currToken.type != .EOF) {
            try nodes.append(evalExpr())
        }
        
        return SyntaxTree(nodes: nodes)
    }
    
    ///Handle evalExpr <expr> -> <term> { ( + | - ) <term> }
    private func evalExpr() throws -> SyntaxNode {
        var expr = try evalTerm()
        
        switch (currToken.type) {
        //current token is add or sub
        case .ADD, .SUB:
            //save current expr
            let _op = currToken
            nextTok()
            
            let _rightOp = try evalTerm()
            expr = try OpNode(LeftOp: expr, RightOp: _rightOp, op: _op)
            
            //left associate any potential next adds or subtracts
            while(currToken.type == .ADD || currToken.type == .SUB) {
                let _op = currToken
                nextTok()
                
                expr = try OpNode(LeftOp: expr, RightOp: evalTerm(), op: _op)
            }
            return expr
        default:
            return expr
        }
    }
    
    ///Handle term <term> -> <power> { * | / } <power>
    private func evalTerm() throws -> SyntaxNode {
        var term = try evalPower()
        
        switch (currToken.type) {
        case .MULT, .DIV:
            let _op = currToken
            nextTok()
            
            term = try OpNode(LeftOp: term, RightOp: evalPower(), op: _op)
            
            while(currToken.type == .MULT || currToken.type == .DIV) {
                let _op = currToken
                nextTok()
                
                term = try OpNode(LeftOp: term, RightOp: evalPower(), op: _op)
            }
            return term
        default:
            return term
        }
    }
    
    ///Handle Power <power> -> <power> [( ** | // ) <power> ]
    private func evalPower() throws -> SyntaxNode {
        let power = try evalUnary()
        
        switch ( currToken.type ) {
        case .EXP, .ROOT:
            let _op = currToken
            nextTok()
            
            //this is RIGHT associative via recursive call
            return try OpNode(LeftOp: power, RightOp: evalPower(), op: _op)
        default:
            return power
        }
    }
    
    ///Handle Unary <unary>  → [ - ] <id>
    private func evalUnary() throws -> SyntaxNode {
        if (currToken.type == .SUB) {
            nextTok()
            let node = try evalID()
            return UnaryNode(node: node)
        }
        return try evalID()
    }
    ///Handle ID <ID> -> <real> | ( <expr> ) | sin(<expr> ) | cos(<expr>) | tan(<expr>) | x | z
    private func evalID() throws -> SyntaxNode {
        let node: SyntaxNode
        switch( currToken.type ) {
        case .NUMBER:
            node = try NumNode(token: currToken)
            nextTok() // we are ready for next token
        case .LPAREN:
            nextTok() //go past parens
            node = try evalExpr()
            
            //assert next token is a RParen
            try assertTok(")") //move to next token and check
        case .SIN, .COS, .TAN:
            //current token with our math operation
            let mathTok: Token = currToken
            nextTok()
            
            //assert next tok is Lparen
            try assertTok("(")
            let nodeTok: SyntaxNode = try evalExpr()
            node = try FuncNode(node: nodeTok,function: mathTok)
            
            //assert next tok is RParen
            try assertTok(")")
        case .X, .Y:
            node = try IdNode(ID: currToken)
            nextTok() //we are ready for the next token
        case .UNKNOWN:
            Log.Lang.error("Recieved Unknown Token \(currToken)")
            throw ParseError.UnknownToken
        default:
            Log.Lang.error("Invalid syntax expected ID rule not \(currToken)")
            throw ParseError.InvalidState
        }
        return node
    }
    
    /// Assert that the current token has some value
    /// - Parameter expectedVal: Expected value of that token
    private func assertTok(_ expectedVal: String) throws {
        if currToken.val != expectedVal {
            Log.Lang.error("Expected \(expectedVal) but got token with type: \(currToken.type) and val: \(currToken.val)")
            throw ParseError.InvalidSyntax
        }
        
        //move past asserted token
        currToken = lexer.nextToken()
    }
    
    ///move to next token in the stream 
    private func nextTok() {
        currToken = lexer.nextToken()
    }
}

/// Errors that the Parser may through
enum ParseError : Error {
    case InvalidNodeCreation
    case InvalidSyntax
    case UnknownToken
    case InvalidState
}
