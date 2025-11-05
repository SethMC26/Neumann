/**
 Unit tests for `CharStream` (MathLang character stream).

 These tests exercise whitespace skipping, type classification
 (TEXT, DIGIT, DOT, OTHER, EOF), `unread()` behavior, and edge cases.

 Author: GitHub Copilot (AI assistant)
 */
import Foundation
import Testing
@testable import VonViz

struct CharStreamTests {

    enum TestFailure: Error {
        case fail(String)
    }

    private func ensure(_ cond: Bool, _ msg: String) throws {
        if !cond { throw TestFailure.fail(msg) }
    }

    @Test func read_skips_whitespace_and_reports_types() async throws {
        // input has leading whitespace, text, digits, dot, digit, other and trailing spaces
        let cs = CharStream(characters: "  x12.3 + ")

        var r = cs.read()
        try ensure(r.type == .TEXT && r.value == "x", "Expected first read to be TEXT 'x' but got \(r)")

        r = cs.read()
        try ensure(r.type == .DIGIT && r.value == "1", "Expected DIGIT '1' but got \(r)")

        r = cs.read()
        try ensure(r.type == .DIGIT && r.value == "2", "Expected DIGIT '2' but got \(r)")

        r = cs.read()
        try ensure(r.type == .DOT && r.value == ".", "Expected DOT '.' but got \(r)")

        r = cs.read()
        try ensure(r.type == .DIGIT && r.value == "3", "Expected DIGIT '3' but got \(r)")

        r = cs.read()
        try ensure(r.type == .OTHER && r.value == "+", "Expected OTHER '+' but got \(r)")

        // consume trailing whitespace then EOF
        r = cs.read()
        try ensure(r.type == .EOF, "Expected EOF but got \(r)")
    }

    @Test func unread_allows_re_read_of_last_char() async throws {
        let cs = CharStream(characters: "ab")
        var r = cs.read()
        try ensure(r.value == "a", "Expected 'a' first")
        r = cs.read()
        try ensure(r.value == "b", "Expected 'b' second")

        // unread should step back so next read returns 'b' again
        cs.unread()
        r = cs.read()
        try ensure(r.value == "b", "Expected 'b' after unread")

        // now EOF
        r = cs.read()
        try ensure(r.type == .EOF, "Expected EOF after reads")
    }

    @Test func unread_at_start_is_noop_and_read_returns_first_char() async throws {
        let cs = CharStream(characters: "Z")
        // unread at start should not move before start; read should return the only char
        cs.unread()
        let r = cs.read()
        try ensure(r.type == .TEXT && r.value == "z", "Expected TEXT 'z' (lowercased) after unread at start but got \(r)")
    }

    @Test func empty_input_returns_eof() async throws {
        let cs = CharStream(characters: "")
        let r = cs.read()
        try ensure(r.type == .EOF && r.value == "\0", "Expected EOF with null char for empty input but got \(r)")
    }

    @Test func dot_and_other_chars_classified_correctly() async throws {
        let cs = CharStream(characters: ".@")
        var r = cs.read()
        try ensure(r.type == .DOT && r.value == ".", "Expected DOT for '.' but got \(r)")
        r = cs.read()
        try ensure(r.type == .OTHER && r.value == "@", "Expected OTHER for '@' but got \(r)")
        r = cs.read()
        try ensure(r.type == .EOF, "Expected EOF at end")
    }

    @Test func whitespace_only_input_returns_eof() async throws {
        let cs = CharStream(characters: "    \t  \n  ")
        let r = cs.read()
        try ensure(r.type == .EOF, "Expected EOF for whitespace-only input but got \(r)")
    }

}

extension CharStreamTests {
    /// Run all char stream tests as a suite (callable from main test entry)
    static func run() async throws {
        let inst = CharStreamTests()
        try await inst.read_skips_whitespace_and_reports_types()
        try await inst.unread_allows_re_read_of_last_char()
        try await inst.unread_at_start_is_noop_and_read_returns_first_char()
        try await inst.empty_input_returns_eof()
        try await inst.dot_and_other_chars_classified_correctly()
        try await inst.whitespace_only_input_returns_eof()
    }
}
