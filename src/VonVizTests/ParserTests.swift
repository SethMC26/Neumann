/**
 Unit tests for the MathLang Parser.

 These tests verify operator precedence, associativity, function calls,
 AST evaluation semantics, and a selection of error conditions.

 Author: GitHub Copilot (AI assistant)
 */
import Foundation
@testable import VonViz

struct ParserTestsSuite {

    enum SuiteFailure: Error {
        case fail(String)
    }

    private static func ensure(_ cond: Bool, _ msg: String) throws {
        if !cond { throw SuiteFailure.fail(msg) }
    }

    static func run() async throws {
        // parser_precedence_and_eval
        do {
            var p = Parser(input: "1+2*3")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(val == 7.0, "Expected 1+2*3 == 7 but got \(val)")

            p = Parser(input: "(1+2)*3")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(val == 9.0, "Expected (1+2)*3 == 9 but got \(val)")

            p = Parser(input: "2**3**2")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(val == 512.0, "Expected 2**3**2 == 512 but got \(val)")
        }

        // parser_functions_and_ids
        do {
            var p = Parser(input: "sin(0) + cos(0)")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(abs(val - 1.0) < 1e-12, "Expected sin(0)+cos(0) == 1 but got \(val)")

            p = Parser(input: "x + z")
            tree = try p.parse()
            val = try tree.eval(2.0, 3.0)
            try ensure(val == 5.0, "Expected x+z with x=2,z=3 to equal 5 but got \(val)")
        }

        // parser_multiple_nodes_sum
        do {
            let p = Parser(input: "1 2 3")
            let tree = try p.parse()
            let val = try tree.eval(0,0)
            try ensure(val == 6.0, "Expected sum 1+2+3 == 6 but got \(val)")
        }

        // parser_left_associative_add_sub
        do {
            let p = Parser(input: "10-3-2")
            let tree = try p.parse()
            let val = try tree.eval(0,0)
            try ensure(val == 5.0, "Expected (10-3)-2 == 5 but got \(val)")
        }

        // parser_left_associative_mult_div
        do {
            var p = Parser(input: "8/4/2")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(val == 1.0, "Expected 8/4/2 == 1 but got \(val)")

            p = Parser(input: "1+2*3+4")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(val == 11.0, "Expected 1+2*3+4 == 11 but got \(val)")
        }

        // parser_root_and_exponent_eval
        do {
            var p = Parser(input: "27//3")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(abs(val - 3.0) < 1e-12, "Expected 27//3 == 3 but got \(val)")

            p = Parser(input: "9**(1/2)")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(abs(val - 3.0) < 1e-12, "Expected 9**(1/2) == 3 but got \(val)")
        }

        // parser_unary_minus_and_errors
        do {
            do {
                _ = try Parser(input: "-1").parse()
                throw SuiteFailure.fail("Expected parse to throw for unary minus but it succeeded")
            } catch let e as ParseError {
                try ensure(e == .InvalidState || e == .InvalidSyntax, "Expected InvalidState or InvalidSyntax for unary minus but got \(e)")
            }

            do {
                _ = try Parser(input: "(1+2").parse()
                throw SuiteFailure.fail("Expected parse to throw InvalidSyntax for unmatched paren but it succeeded")
            } catch let e as ParseError {
                try ensure(e == .InvalidSyntax, "Expected InvalidSyntax for mismatched paren but got \(e)")
            }

            do {
                _ = try Parser(input: "abc").parse()
                throw SuiteFailure.fail("Expected parse to throw UnknownToken for 'abc' but it succeeded")
            } catch let e as ParseError {
                try ensure(e == .UnknownToken, "Expected UnknownToken for 'abc' but got \(e)")
            }
        }

        // parser_function_edge_cases_eval
        do {
            var p = Parser(input: "sin(0)")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(abs(val - 0.0) < 1e-12, "Expected sin(0) == 0 but got \(val)")

            p = Parser(input: "cos(0)")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(abs(val - 1.0) < 1e-12, "Expected cos(0) == 1 but got \(val)")

            p = Parser(input: "tan(0)")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(abs(val - 0.0) < 1e-12, "Expected tan(0) == 0 but got \(val)")
        }

        // nested functions and division by zero
        do {
            var p = Parser(input: "sin(cos(0))")
            var tree = try p.parse()
            var val = try tree.eval(0,0)
            try ensure(abs(val - sin(cos(0.0))) < 1e-12, "Expected sin(cos(0)) == sin(cos(0)) but got \(val)")

            p = Parser(input: "1/0")
            tree = try p.parse()
            val = try tree.eval(0,0)
            try ensure(val.isInfinite && val > 0, "Expected 1/0 to be +infinity but got \(val)")
        }
    }

}
