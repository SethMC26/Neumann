//
//  VonVizTests.swift
//  VonVizTests
//
//  Created by Kayla Quinlan on 9/14/25.
//

/**
 Main test entry that aggregates and runs the test suites.

 Each `@Test` method delegates to a suite implemented in a separate file.

 Author: GitHub Copilot (AI assistant)
 */
import Testing
@testable import VonViz

/// Main test entry that calls lexer and parser suites located in separate files
struct VonVizTests {

    @Test func runLexerSuite() async throws {
        try await LexerTestsSuite.run()
    }

    @Test func runParserSuite() async throws {
        try await ParserTestsSuite.run()
    }

    @Test func runModelSuite() async throws {
        try await ModelTests.run()
    }

    @Test func runCharStreamSuite() async throws {
        try await CharStreamTests.run()
    }

}
