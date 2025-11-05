/**
 Unit tests for the MathLang Lexer.

 These tests exercise tokenization behaviors including numbers, operators,
 multi-character tokens ("**", "//"), function keywords, unknown tokens,
 and several edge cases.

 Author: GitHub Copilot (AI assistant)
 */
import Foundation
@testable import VonViz

struct LexerTestsSuite {

    enum SuiteFailure: Error {
        case fail(String)
    }

    private static func ensure(_ cond: Bool, _ msg: String) throws {
        if !cond { throw SuiteFailure.fail(msg) }
    }

    static func run() async throws {
        // lexer_numbers
        do {
            let lex = Lexer(input: "12 3.45")
            let t1 = lex.nextToken()
            try ensure(t1.type == .NUMBER && t1.val == "12", "Expected first token to be NUMBER(12) but got \(t1)")

            let t2 = lex.nextToken()
            try ensure(t2.type == .NUMBER && t2.val == "3.45", "Expected second token to be NUMBER(3.45) but got \(t2)")

            let t3 = lex.nextToken()
            try ensure(t3.type == .EOF, "Expected EOF but got \(t3)")
        }

        // lexer_operators_and_funcs
        do {
            let input = "+ - * ** / // ( ) x z sin cos tan abc"
            let lex = Lexer(input: input)

            var t = lex.nextToken(); try ensure(t.type == .ADD, "Expected ADD but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .SUB, "Expected SUB but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .MULT, "Expected MULT but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .EXP, "Expected EXP (**) but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .DIV, "Expected DIV but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .ROOT, "Expected ROOT (//) but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .LPAREN, "Expected LPAREN but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .RPAREN, "Expected RPAREN but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .X, "Expected X but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .Z, "Expected Z but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .SIN, "Expected SIN but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .COS, "Expected COS but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .TAN, "Expected TAN but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .UNKNOWN && t.val == "abc", "Expected UNKNOWN(abc) but got \(t)")
            t = lex.nextToken(); try ensure(t.type == .EOF, "Expected EOF but got \(t)")
        }

        // lexer_unknown_token
        do {
            let lex = Lexer(input: "@ # abc")

            var t = lex.nextToken()
            try ensure(t.type == .UNKNOWN && t.val == "@", "Expected UNKNOWN(@) but got \(t)")
            t = lex.nextToken()
            try ensure(t.type == .UNKNOWN && t.val == "#", "Expected UNKNOWN(#) but got \(t)")
            t = lex.nextToken()
            try ensure(t.type == .UNKNOWN && t.val == "abc", "Expected UNKNOWN(abc) but got \(t)")
            t = lex.nextToken()
            try ensure(t.type == .EOF, "Expected EOF but got \(t)")
        }

        // leading dot followed by digit: should return UNKNOWN('.') then NUMBER('5')
        do {
            let lex = Lexer(input: ".5")
            var t = lex.nextToken()
            try ensure(t.type == .UNKNOWN && t.val == ".", "Expected UNKNOWN('.') for leading dot but got \(t)")
            t = lex.nextToken()
            try ensure(t.type == .NUMBER && t.val == "5", "Expected NUMBER(5) after dot but got \(t)")
        }
    }

}
