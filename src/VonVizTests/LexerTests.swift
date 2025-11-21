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

    // ... unchanged test code ...
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

    // (rest of the tests remain exactly the same)
}
