// MIT License
//
// Copyright (c) 2021 The Kroger Co. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
import Telemetry
import Gauntlet

class SignificanceTests: XCTestCase {

    func testConvenienceAliases() {

        let debug: Facet = .debug
        XCTAssert(debug, is: Significance.self, equalTo: .debug)
        XCTAssertEqual(Significance.debug, Facets.Significance.debug)

        let verbose: Facet = .verbose
        XCTAssert(verbose, is: Significance.self, equalTo: .verbose)
        XCTAssertEqual(Significance.verbose, Facets.Significance.verbose)

        let informational: Facet = .informational
        XCTAssert(informational, is: Significance.self, equalTo: .informational)
        XCTAssertEqual(Significance.informational, Facets.Significance.informational)

        let warning: Facet = .warning
        XCTAssert(warning, is: Significance.self, equalTo: .warning)
        XCTAssertEqual(Significance.warning, Facets.Significance.warning)

        let error: Facet = .error
        XCTAssert(error, is: Significance.self, equalTo: .error)
        XCTAssertEqual(Significance.error, Facets.Significance.error)

        let internalError: Facet = .internalError
        XCTAssert(internalError, is: Significance.self, equalTo: .internalError)
        XCTAssertEqual(Significance.internalError, Facets.Significance.internalError)
    }

    func testFacetConformance() {
        // Given
        let significance = Significance.debug

        // When
        let metron = SomeMetron(facets: [significance])

        // Then
        XCTAssert(metron.facets.contains(type: Significance.self))
    }
}
