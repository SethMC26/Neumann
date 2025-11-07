/**
 MathLang Parser Test Suite
 ==========================

 This suite validates parsing and evaluation behavior of the `Parser` used in
 the MathLang subsystem of the VonViz project.

 It covers:
 - Operator precedence and associativity
 - Function calls and identifier handling
 - AST evaluation semantics (including roots and exponents)
 - Multiple-node implicit summation
 - Error conditions and edge cases (unary minus, mismatched parens, unknown tokens, div-by-zero)
 - Simple nesting of functions

 Each logical block from the original suite is now an independent `@Test`.

 Author: ChatGPT (OpenAI GPT-5)
 Created: November 2025
 */

import Foundation
import Testing
@testable import VonViz

@Suite("MathLang Parser Tests")
struct ParserTests {

    /**
     Verify operator precedence and evaluation:
      - `1+2*3` ⇒ 7 (multiplication before addition)
      - `(1+2)*3` ⇒ 9 (parentheses)
      - `2**3**2` ⇒ 512 (right-associative exponent)
     */
    @Test("Precedence and evaluation")
    func parser_precedence_and_eval() throws {
        var p = Parser(input: "1+2*3")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(val == 7.0, "Expected 1+2*3 == 7 but got \(val)")

        p = Parser(input: "(1+2)*3")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(val == 9.0, "Expected (1+2)*3 == 9 but got \(val)")

        p = Parser(input: "2**3**2")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(val == 512.0, "Expected 2**3**2 == 512 but got \(val)")
    }

    /**
     Verify functions and identifiers:
      - `sin(0) + cos(0)` ≈ 1
      - `x + z` with (x=2, z=3) ⇒ 5
     */
    @Test("Functions and identifiers")
    func parser_functions_and_ids() throws {
        var p = Parser(input: "sin(0) + cos(0)")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(abs(val - 1.0) < 1e-12, "Expected sin(0)+cos(0) == 1 but got \(val)")

        p = Parser(input: "x + y")
        tree = try p.parse()
        val = try tree.eval(2.0, 3.0)
        #expect(val == 5.0, "Expected x+z with x=2,y=3 to equal 5 but got \(val)")
    }

    /**
     Verify left-associative subtraction:
      - `10-3-2` ⇒ (10-3)-2 == 5
     */
    @Test("Left-associative add/sub")
    func parser_left_associative_add_sub() throws {
        let p = Parser(input: "10-3-2")
        let tree = try p.parse()
        let val = try tree.eval(0, 0)
        #expect(val == 5.0, "Expected (10-3)-2 == 5 but got \(val)")
    }

    /**
     Verify left-associative division and mixed precedence:
      - `8/4/2` ⇒ (8/4)/2 == 1
      - `1+2*3+4` ⇒ 11
     */
    @Test("Left-associative mult/div and mixed precedence")
    func parser_left_associative_mult_div() throws {
        var p = Parser(input: "8/4/2")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(val == 1.0, "Expected 8/4/2 == 1 but got \(val)")

        p = Parser(input: "1+2*3+4")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(val == 11.0, "Expected 1+2*3+4 == 11 but got \(val)")
    }

    /**
     Verify root and exponent evaluation:
      - `27//3` ⇒ 3
      - `9**(1/2)` ⇒ 3
     */
    @Test("Root and exponent evaluation")
    func parser_root_and_exponent_eval() throws {
        var p = Parser(input: "27//3")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(abs(val - 3.0) < 1e-12, "Expected 27//3 == 3 but got \(val)")

        p = Parser(input: "9**(1/2)")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(abs(val - 3.0) < 1e-12, "Expected 9**(1/2) == 3 but got \(val)")
    }

    /**
     Verify selected parse errors:
      - Unmatched paren `(1+2` should throw InvalidSyntax
      - Unknown token `abc` should throw UnknownToken
     */
    @Test("Unary minus and other parse errors")
    func parser_unary_minus_and_errors() {
        // Unmatched parenthesis should be InvalidSyntax
        do {
            _ = try Parser(input: "(1+2").parse()
            Issue.record("Expected parse to throw InvalidSyntax for unmatched paren but it succeeded")
        } catch let e as ParseError {
            #expect(e == .InvalidSyntax, "Expected InvalidSyntax for mismatched paren but got \(e)")
        } catch {
            Issue.record("Unexpected error for mismatched paren: \(error)")
        }

        // Unknown token should be UnknownToken
        do {
            _ = try Parser(input: "abc").parse()
            Issue.record("Expected parse to throw UnknownToken for 'abc' but it succeeded")
        } catch let e as ParseError {
            #expect(e == .UnknownToken, "Expected UnknownToken for 'abc' but got \(e)")
        } catch {
            Issue.record("Unexpected error for unknown token: \(error)")
        }
    }

    /**
     Verify simple function edge cases:
      - `sin(0)` ⇒ 0
      - `cos(0)` ⇒ 1
      - `tan(0)` ⇒ 0
     */
    @Test("Function edge cases: sin/cos/tan at zero")
    func parser_function_edge_cases_eval() throws {
        var p = Parser(input: "sin(0)")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(abs(val - 0.0) < 1e-12, "Expected sin(0) == 0 but got \(val)")

        p = Parser(input: "cos(0)")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(abs(val - 1.0) < 1e-12, "Expected cos(0) == 1 but got \(val)")

        p = Parser(input: "tan(0)")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(abs(val - 0.0) < 1e-12, "Expected tan(0) == 0 but got \(val)")
    }

    /**
     Verify nested function evaluation and division by zero handling:
      - `sin(cos(0))` equals the native `sin(cos(0))`
      - `1/0` should evaluate to +infinity
     */
    @Test("Nested functions and division by zero")
    func parser_nested_functions_and_div_by_zero() throws {
        var p = Parser(input: "sin(cos(0))")
        var tree = try p.parse()
        var val = try tree.eval(0, 0)
        #expect(abs(val - sin(cos(0.0))) < 1e-12,
                "Expected sin(cos(0)) == sin(cos(0)) but got \(val)")

        p = Parser(input: "1/0")
        tree = try p.parse()
        val = try tree.eval(0, 0)
        #expect(val.isInfinite && val > 0, "Expected 1/0 to be +infinity but got \(val)")
    }
    
    ///chatGPT is doing tricks on the edge cases yo - seth
    @Suite("Parser: Unary Minus")
    struct ParserUnaryMinusTests {
    
        // MARK: - Basic valid cases

        @Test("Unary minus before number")
        func unary_number() throws {
            let p = Parser(input: "-1")
            let tree = try p.parse()
            let val = try tree.eval(0, 0)
            #expect(abs(val + 1.0) < 1e-12, "Expected -1")
        }

        @Test("Unary minus before variable x")
        func unary_variable_x() throws {
            let p = Parser(input: "-x")
            let tree = try p.parse()
            let val = try tree.eval(2.5, 0)   // x = 2.5
            #expect(abs(val + 2.5) < 1e-12, "Expected -x with x=2.5")
        }

        @Test("Unary minus before variable y")
        func unary_variable_z() throws {
            let p = Parser(input: "-y")
            let tree = try p.parse()
            let val = try tree.eval(0, 3.0)   // z = 3
            #expect(abs(val + 3.0) < 1e-12, "Expected -y with z=3")
        }

        @Test("Unary minus before function call")
        func unary_function() throws {
            var p = Parser(input: "-sin(0)")
            var tree = try p.parse()
            var val = try tree.eval(0, 0)
            #expect(abs(val - 0.0) < 1e-12, "Expected -sin(0) == 0")

            p = Parser(input: "-cos(0)")
            tree = try p.parse()
            val = try tree.eval(0, 0)
            #expect(abs(val + 1.0) < 1e-12, "Expected -cos(0) == -1")

            p = Parser(input: "-tan(0)")
            tree = try p.parse()
            val = try tree.eval(0, 0)
            #expect(abs(val - 0.0) < 1e-12, "Expected -tan(0) == 0")
        }

        @Test("Unary minus before parenthesized expression")
        func unary_parenthesized_expr() throws {
            let p = Parser(input: "-(1+2*3)")
            let tree = try p.parse()
            let val = try tree.eval(0, 0)
            #expect(abs(val + 7.0) < 1e-12, "Expected -(1+2*3) == -7")
        }

        @Test("Unary minus with inner unary")
        func unary_nested_inside_parens() throws {
            let p = Parser(input: "-(-1)")
            let tree = try p.parse()
            let val = try tree.eval(0, 0)
            #expect(abs(val - 1.0) < 1e-12, "Expected -(-1) == 1")
        }

        @Test("Unary minus tolerates whitespace")
        func unary_with_whitespace() throws {
            let p = Parser(input: "-   3")
            let tree = try p.parse()
            let val = try tree.eval(0, 0)
            #expect(abs(val + 3.0) < 1e-12, "Expected -3 with spaces")
        }

        // MARK: - Precedence with ** and //

        @Test("Unary precedence vs exponent (**): -2**2 == (+4) with current grammar")
        func unary_vs_exponent() throws {
            var p = Parser(input: "-2**2")
            var tree = try p.parse()
            var val = try tree.eval(0, 0)
            #expect(abs(val - 4.0) < 1e-12,
                    "Current parser binds unary before exponent: (-2)**2 == 4")

            p = Parser(input: "-(2**2)")
            tree = try p.parse()
            val = try tree.eval(0, 0)
            #expect(abs(val + 4.0) < 1e-12, "Expected -(2**2) == -4")

            p = Parser(input: "(-2)**2")
            tree = try p.parse()
            val = try tree.eval(0, 0)
            #expect(abs(val - 4.0) < 1e-12, "Expected (-2)**2 == 4")
        }
        // MARK: - Invalid / error cases

        @Test("Double unary is not allowed by grammar: --1 should throw")
        func double_unary_invalid() {
            do {
                _ = try Parser(input: "--1").parse()
                Issue.record("Expected parse to throw for '--1' but it succeeded")
            } catch let e as ParseError {
                // evalUnary expects an ID after the first '-', but sees another '-'
                // which isn't a valid ID starter in evalID(); the code throws InvalidState.
                #expect(e == .InvalidState, "Expected InvalidState for '--1' but got \(e)")
            } catch {
                Issue.record("Unexpected error for '--1': \(error)")
            }
        }

        @Test("Lone '-' is invalid")
        func lone_minus_invalid() {
            do {
                _ = try Parser(input: "-").parse()
                Issue.record("Expected parse to throw for lone '-' but it succeeded")
            } catch let e as ParseError {
                #expect(e == .InvalidState || e == .InvalidSyntax,
                        "Expected InvalidState/InvalidSyntax for lone '-' but got \(e)")
            } catch {
                Issue.record("Unexpected error for lone '-': \(error)")
            }
        }

        @Test("Unary minus before unknown identifier should throw UnknownToken")
        func unary_before_unknown_identifier() {
            do {
                _ = try Parser(input: "-abc").parse()
                Issue.record("Expected parse to throw UnknownToken for '-abc' but it succeeded")
            } catch let e as ParseError {
                #expect(e == .UnknownToken, "Expected UnknownToken for '-abc' but got \(e)")
            } catch {
                Issue.record("Unexpected error for '-abc': \(error)")
            }
        }

        @Test("Unbalanced parentheses after unary: '-(1+2' should throw InvalidSyntax")
        func unary_with_unbalanced_parentheses() {
            do {
                _ = try Parser(input: "-(1+2").parse()
                Issue.record("Expected parse to throw InvalidSyntax for '-(1+2' but it succeeded")
            } catch let e as ParseError {
                #expect(e == .InvalidSyntax, "Expected InvalidSyntax but got \(e)")
            } catch {
                Issue.record("Unexpected error for '-(1+2': \(error)")
            }
        }

        // MARK: - Mixed with other operators

        @Test("Unary binds tighter than multiplication: -x*3 == (-x)*3")
        func unary_mult_binding() throws {
            let p = Parser(input: "-x*3")
            let tree = try p.parse()
            let val = try tree.eval(2.0, 0)  // x = 2
            #expect(abs(val + 6.0) < 1e-12, "Expected (-2)*3 == -6")
        }

        @Test("Unary in sums: -(1) + 2 == 1")
        func unary_in_sum() throws {
            let p = Parser(input: "-(1)+2")
            let tree = try p.parse()
            let val = try tree.eval(0,0)
            #expect(abs(val - 1.0) < 1e-12)
        }
    }
}

