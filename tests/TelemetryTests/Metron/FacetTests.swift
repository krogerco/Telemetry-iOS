// MIT License
//
// Copyright (c) 2019 The Kroger Co. All rights reserved.
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

@testable import Telemetry
import Gauntlet
import XCTest

class FacetTests: XCTestCase {
    func testArrayFacetOfType() {
        // Given, When
        let facets: [Facet] = [TestFacet.isEven, .debug]

        // Then
        XCTAssertEqual(facets.first(ofType: TestFacet.self), .isEven)
        XCTAssertEqual(facets.first(ofType: Significance.self), .debug)
        XCTAssertFalse(facets.contains(type: Prefix.self))
    }

    func testArrayHasFacetOfType() {
        // Given, When
        let facets: [Facet] = [TestFacet.isEven, Significance.debug]

        // Then
        XCTAssertTrue(facets.contains(type: TestFacet.self))
        XCTAssertTrue(facets.contains(type: Significance.self))
        XCTAssertFalse(facets.contains(type: Prefix.self))
    }

    func testArrayHasFacet() {
        // Given, When
        let facets: [Facet] = [TestFacet.isEven, .debug]

        // Then
        XCTAssertTrue(facets.contains(TestFacet.isEven))
        XCTAssertTrue(facets.contains(Significance.debug))
        XCTAssertFalse(facets.contains(Significance.warning))
        XCTAssertFalse(facets.contains(Prefix("Hello")))
    }

    func testArrayHasOneOf() {
        // Given, When
        let facets: [Facet] = [TestFacet.isEven, Significance.debug]

        // Then
        XCTAssertTrue(facets.containsAny([TestFacet.isEven, TestFacet.other]))
        XCTAssertTrue(facets.containsAny([Significance.warning, Significance.debug]))
        XCTAssertFalse(facets.containsAny([Significance.warning, Significance.error]))
    }

    func testArrayConvenience() {
        // Given, When
        let facets: [Facet] = [
            Significance.debug,
            Significance.error
        ]

        // Then
        XCTAssertEqual(facets.significance, .debug)
    }

    func testArrayFacetOfTypeOrder() {
        // Given, When
        let facets: [Facet] = [
            TestFacet.isEven,
            Significance.debug,
            TestFacet.something]

        // Then
        XCTAssertEqual(facets.first(ofType: TestFacet.self), .isEven)
        XCTAssertEqual(facets.first(ofType: Significance.self), .debug)
        XCTAssertFalse(facets.contains(type: Prefix.self))
    }

    func testFacetsNamespaceTypeAliases() {
        XCTAssert(Facets.Significance.verbose, is: Significance.self)
        XCTAssert(Facets.Prefix(#function), is: Prefix.self)
        XCTAssert(Facets.File(), is: File.self)
        XCTAssert(Facets.Failure(SomeError()), is: Failure.self)
    }

    func testFilterType() {

        // Given
        let allFacets: [Facet] = [
            Prefix("Hello"),
            TestFacet.something,
            OtherFacet.blah,
            Prefix("World"),
            TestFacet.other
        ]

        let expectedPrefixFacets: [Prefix] = [Prefix("Hello"), Prefix("World")]
        let expectedTestFacets: [TestFacet] = [.something, .other]

        // When
        let filteredPrefix = allFacets.filter(by: Prefix.self)
        let filteredTests = allFacets.filter(by: TestFacet.self)

        // Then
        XCTAssertEqual(filteredPrefix, expectedPrefixFacets)
        XCTAssertEqual(filteredTests, expectedTestFacets)
    }

    func testPrefixAccessor() {

        // Given
        let allFacets: [Facet] = [
            Prefix("🔵"),
            Prefix("Hello"),
            TestFacet.something,
            OtherFacet.blah,
            Prefix("World"),
            TestFacet.other,
            Prefix("🟢")
        ]

        let expectedPrefixString = "🔵 Hello World 🟢"

        // When
        let defaultPrefix = allFacets.prefix

        // Then
        XCTAssertEqual(defaultPrefix, expectedPrefixString)
    }

}
