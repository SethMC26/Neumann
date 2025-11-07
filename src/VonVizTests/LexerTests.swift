/**
 MathLang Lexer Test Suite
 =========================

 This suite validates tokenization behavior of the `Lexer` used in the MathLang
 subsystem of the VonViz project.

 It tests a variety of cases including:
 - Numeric literals (integers and floats)
 - Operators and multi-character symbols (`**`, `//`)
 - Function and variable identifiers (`sin`, `cos`, `x`, etc.)
 - Unknown or unrecognized tokens
 - Edge cases such as leading dots

 Each test is isolated and uses the Swift Testing framework (`@Test`, `#expect`).

 Author: ChatGPT (OpenAI GPT-5)
 Created: November 2025
 */

import Testing
@testable import VonViz

@Suite("MathLang Lexer Tests")
struct LexerTests {

    /**
     Test numeric tokenization and operator parsing.
     
     Verifies that:
      - Integers and decimals are correctly identified as `.NUMBER`
      - The addition operator is correctly parsed as `.ADD`
      - The lexer terminates with `.EOF`
     */
    @Test("Lexer numbers")
    func lexer_numbers() throws {
        let lex = Lexer(input: "12 + 3.45")

        let t1 = lex.nextToken()
        #expect(t1.type == .NUMBER && t1.val == "12", "Expected NUMBER(12) but got \(t1)")

        let tplus = lex.nextToken()
        #expect(tplus.type == .ADD && tplus.val == "+", "Expected ADD(+) but got \(tplus)")

        let t2 = lex.nextToken()
        #expect(t2.type == .NUMBER && t2.val == "3.45", "Expected NUMBER(3.45) but got \(t2)")

        let t3 = lex.nextToken()
        #expect(t3.type == .EOF, "Expected EOF but got \(t3)")
    }

    /**
     Test operator and function tokenization.

     Verifies correct recognition of:
      - Basic operators (`+`, `-`, `*`, `/`)
      - Multi-character operators (`**` for exponent, `//` for root)
      - Parentheses
      - Variables (`x`, `z`)
      - Function identifiers (`sin`, `cos`, `tan`)
      - Unknown identifiers
     */
    @Test("Operators and function tokens")
    func lexer_operators_and_funcs() throws {
        let input = "+ - ** * // / ( ) x z sin( cos( tan( abc"
        let lex = Lexer(input: input)

        var t = lex.nextToken(); #expect(t.type == .ADD, "Expected ADD but got \(t)")
        t = lex.nextToken(); #expect(t.type == .SUB, "Expected SUB but got \(t)")
        t = lex.nextToken(); #expect(t.type == .EXP, "Expected EXP(**) but got \(t)")
        t = lex.nextToken(); #expect(t.type == .MULT, "Expected MULT but got \(t)")
        t = lex.nextToken(); #expect(t.type == .ROOT, "Expected ROOT(//) but got \(t)")
        t = lex.nextToken(); #expect(t.type == .DIV, "Expected DIV but got \(t)")
        t = lex.nextToken(); #expect(t.type == .LPAREN, "Expected LPAREN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .RPAREN, "Expected RPAREN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .X, "Expected X but got \(t)")
        t = lex.nextToken(); #expect(t.type == .Z, "Expected Z but got \(t)")
        t = lex.nextToken(); #expect(t.type == .SIN, "Expected SIN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .LPAREN, "Expected LPAREN but got \(t)") // need character to seperate math funcs
        t = lex.nextToken(); #expect(t.type == .COS, "Expected COS but got \(t)")
        t = lex.nextToken(); #expect(t.type == .LPAREN, "Expected LPAREN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .TAN, "Expected TAN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .LPAREN, "Expected LPAREN but got \(t)")
        t = lex.nextToken(); #expect(t.type == .UNKNOWN && t.val == "abc", "Expected UNKNOWN(abc) but got \(t)")
        t = lex.nextToken(); #expect(t.type == .EOF, "Expected EOF but got \(t)")
    }

    /**
     Test unknown token handling.
     
     Ensures that non-recognized symbols are returned as `.UNKNOWN` tokens
     and that the lexer ends with `.EOF`.
     */
    @Test("Unknown tokens")
    func lexer_unknown_token() throws {
        let lex = Lexer(input: "@ # abc")

        var t = lex.nextToken()
        #expect(t.type == .UNKNOWN && t.val == "@", "Expected UNKNOWN(@) but got \(t)")

        t = lex.nextToken()
        #expect(t.type == .UNKNOWN && t.val == "#", "Expected UNKNOWN(#) but got \(t)")

        t = lex.nextToken()
        #expect(t.type == .UNKNOWN && t.val == "abc", "Expected UNKNOWN(abc) but got \(t)")

        t = lex.nextToken()
        #expect(t.type == .EOF, "Expected EOF but got \(t)")
    }

    /**
     Test handling of a leading dot followed by digits.
     
     Verifies that:
      - A leading '.' not followed by digits is `.UNKNOWN`
      - Subsequent digits form a `.NUMBER`
     */
    @Test("Leading dot followed by digit")
    func lexer_leading_dot_number() throws {
        let lex = Lexer(input: ".5")

        var t = lex.nextToken()
        #expect(t.type == .UNKNOWN && t.val == ".", "Expected UNKNOWN('.') for leading dot but got \(t)")

        t = lex.nextToken()
        #expect(t.type == .NUMBER && t.val == "5", "Expected NUMBER(5) after dot but got \(t)")
    }
    
    @Test("EOF after identifier")
    func eof_after_identifier() {
        let lex = Lexer(input: "abc")
        var t = lex.nextToken(); #expect(t.type == .UNKNOWN && t.val == "abc")
        t = lex.nextToken();     #expect(t.type == .EOF)
    }

    @Test("EOF after number")
    func eof_after_number() {
        let lex = Lexer(input: "123")
        var t = lex.nextToken(); #expect(t.type == .NUMBER && t.val == "123")
        t = lex.nextToken();     #expect(t.type == .EOF)
    }

    @Test("EOF after single * or /")
    func eof_after_single_star_or_slash() {
        var lex = Lexer(input: "*")
        var t = lex.nextToken(); #expect(t.type == .MULT)
        t = lex.nextToken();     #expect(t.type == .EOF)

        lex = Lexer(input: "/")
        t = lex.nextToken();     #expect(t.type == .DIV)
        t = lex.nextToken();     #expect(t.type == .EOF)
    }

    @Test("EOF after ** and //")
    func eof_after_double_ops() {
        var lex = Lexer(input: "**")
        var t = lex.nextToken(); #expect(t.type == .EXP)
        t = lex.nextToken();     #expect(t.type == .EOF)

        lex = Lexer(input: "//")
        t = lex.nextToken();     #expect(t.type == .ROOT)
        t = lex.nextToken();     #expect(t.type == .EOF)
    }

}

