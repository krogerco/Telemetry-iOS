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
import Foundation
import Gauntlet
import XCTest

class MetroidTestCase: XCTestCase {

    struct EmptyMetron: Metron, Equatable {
        let message: String = "An empty metron."
    }

    func testInitAdditionalFacetsArePrioritizedOverMetronFacets() {

        enum MockFacet: Facet {
            case one, two, three, four
        }

        struct MockMetron: Metron {
            let message = "Mock Metron"
            let facets: [Facet] = [MockFacet.three, MockFacet.four]
        }

        // Given
        let metron = MockMetron()
        let additionalFacets: [Facet] = [MockFacet.one, MockFacet.two]
        let expectedFacets: [MockFacet] = [.one, .two, .three, .four]

        // When
        let metroid = Metroid<Metron>(metron: metron, value: metron, additionalFacets: additionalFacets, timestamp: Date())
        let metroidFacets = metroid.facets.filter(by: MockFacet.self)

        // Then
        XCTAssertEqual(metroidFacets, expectedFacets, "Didn't prioritize `addtionalFacets` over `metron.facets`")
    }

    func testInitWithSignificance() {

        // Given
        let empty = EmptyMetron()
        let additionalFacets: [Facet] = [.informational]
        let expectedFacets: [Significance] = [.informational]

        // When
        let metroid = Metroid<Metron>(metron: empty, value: empty, additionalFacets: additionalFacets, timestamp: Date())
        let significanceFacets = metroid.facets.filter(by: Significance.self)

        // Then
        XCTAssertEqual(metroid.significance, .informational)
        XCTAssertEqual(significanceFacets, expectedFacets)

    }

    func testInitWithoutFailureNorSignificance() {

        // Given
        let empty = EmptyMetron()
        let additionalFacets: [Facet] = []
        let expectedFacets: [Significance] = [.verbose]

        // When
        let metroid = Metroid<Metron>(metron: empty, value: empty, additionalFacets: additionalFacets, timestamp: Date())
        let significanceFacets = metroid.facets.filter(by: Significance.self)

        // Then
        XCTAssertEqual(metroid.significance, .verbose)
        XCTAssertEqual(significanceFacets, expectedFacets)
    }

    func testInitWithFailureAndNoSignificance() {

        struct MockError: Error {}

        // Given
        let empty = EmptyMetron()
        let additionalFacets: [Facet] = [Failure(MockError())]
        let expectedSignificance: [Significance] = [.error]
        let expectedFailures: [Failure] = [Failure(MockError())]

        // When
        let metroid = Metroid<Metron>(metron: empty, value: empty, additionalFacets: additionalFacets, timestamp: Date())
        let significanceFacets = metroid.facets.filter(by: Significance.self)
        let failureFacets = metroid.facets.filter(by: Failure.self)

        // Then
        XCTAssertEqual(metroid.significance, .error)
        XCTAssertEqual(significanceFacets, expectedSignificance, "Didn't infer .error based on `Failure` facet.")
        XCTAssertEqual(failureFacets, expectedFailures)
    }

    func testInitMessageWithPrefixes() {

        struct SampleMetron: Metron {
            let message: String = "NamedMetron"
            let facets: [Facet] = [Prefix("3️⃣")]
        }

        // Given
        let metron = SampleMetron()
        let additionalFacets: [Facet] = [Prefix("1️⃣"), Prefix("2️⃣")]
        let expectedMessage = "1️⃣ 2️⃣ 3️⃣ NamedMetron" // Spaces added

        // When
        let metroid = Metroid<Metron>(metron: metron, value: metron, additionalFacets: additionalFacets, timestamp: Date())

        // Then
        XCTAssertEqual(metroid.message, expectedMessage)
    }

    func testInitValue() {

        // Given
        let metron = EmptyMetron()
        let stringValue = "Some String"
        let metronValue = EmptyMetron()
        let intValue = 1028342

        // When
        let stringMetroid = Metroid<String>(metron: metron, value: stringValue, additionalFacets: [], timestamp: Date())
        let metronMetroid = Metroid<EmptyMetron>(metron: metron, value: metronValue, additionalFacets: [], timestamp: Date())
        let intMetroid = Metroid<Int>(metron: metron, value: intValue, additionalFacets: [], timestamp: Date())

        // Then
        XCTAssertEqual(stringMetroid.value, stringValue)
        XCTAssertEqual(metronMetroid.value, metronValue)
        XCTAssertEqual(intMetroid.value, intValue)
    }

    func testInitDate() {

        // Given
        let metron = EmptyMetron()
        let expectedDate = Date(timeIntervalSinceReferenceDate: 99999999999)

        // When
        let metroid = Metroid<Metron>(metron: metron, value: metron, additionalFacets: [], timestamp: expectedDate)

        // Then
        XCTAssertEqual(metroid.timestamp, expectedDate)
    }

    func testCompleteInitialization() {

        enum SampleFacet: Facet, Equatable {
            case one, two, three, four
        }

        struct SampleMetron: Metron {
            let id: String
            let message: String = "Sample Metron"
            let facets: [Facet] = [
                Significance.informational,
                Prefix("🤯"),
                SampleFacet.one,
                SampleFacet.two
            ]
        }

        // Given
        let date = Date(timeIntervalSinceReferenceDate: 7777777777777)
        let metron = SampleMetron(id: #function)
        let additionalFacets: [Facet] = [
            Prefix("😬"),
            Prefix("⚠️"),
            SampleFacet.three,
            SampleFacet.four
        ]

        let expectedFacetCount = 8
        let expectedMessage = "😬 ⚠️ 🤯 Sample Metron"
        let expectedPrefixes = [Prefix("😬"), Prefix("⚠️"), Prefix("🤯")]
        let expectedSignificace = Significance.informational
        let expectedSampleFacet = SampleFacet.three

        // When
        let metroid = Metroid<SampleMetron>(metron: metron, value: metron, additionalFacets: additionalFacets, timestamp: date)

        // Then
        XCTAssertEqual(metroid.message, expectedMessage)
        XCTAssertEqual(metroid.value.id, metron.id)
        XCTAssertEqual(metroid.significance, expectedSignificace)
        XCTAssertEqual(metroid.timestamp, date)

        XCTAssertEqual(metroid.facets.count, expectedFacetCount)
        XCTAssertEqual(metroid.facets.first(ofType: Significance.self), expectedSignificace)
        XCTAssertEqual(metroid.facets.first(ofType: SampleFacet.self), expectedSampleFacet)
        XCTAssertEqual(metroid.facets.filter(by: Prefix.self), expectedPrefixes)
    }

    // MARK: - Description

    func testMetroidDescription() {
        let metron = SomeMetron()
        let metroid = Metroid(SomeMetron())
        XCTAssert(metroid.description, contains: "\(type(of: metron))")
    }

    func testDescriptionUsesMetronDescription() {

        struct SampleMetron: Metron, CustomStringConvertible {
            var description: String { self.message }
            var message: String = "A Sample Metron"
        }

        // Given
        let metroid = Metroid(SampleMetron())

        // When
        let desc = metroid.description

        // Then
        XCTAssertEqual(desc, "Metroid<SampleMetron>: A Sample Metron")
    }

    func testPublicInferredInitializer() {

        // Given
        let typedMetron: SomeMetron = SomeMetron(facets: [.verbose])
        let expectedDate = Date()
        let expectedFacets: [Significance] = [.error, .verbose]

        // When
        let metroid = Metroid(typedMetron, additionalFacets: [.error], timestamp: expectedDate)

        // Then
        XCTAssert(metroid.value, is: SomeMetron.self)
        XCTAssertEqual(String(describing: type(of: metroid)), "Metroid<SomeMetron>")
        XCTAssertEqual(metroid.timestamp, expectedDate)
        XCTAssertEqual(metroid.facets.count, expectedFacets.count)
        XCTAssertEqual(metroid.facets.filter(by: Significance.self), expectedFacets)
    }

    func testPublicMetronInitializer() {

        // Given
        let typedMetron: Metron = SomeMetron(facets: [.verbose])
        let expectedDate = Date()
        let expectedFacets: [Significance] = [.error, .verbose]

        // When
        let metroid = Metroid(typedMetron, additionalFacets: [.error], timestamp: expectedDate)

        // Then
        XCTAssertEqual(String(describing: type(of: metroid)), "Metroid<Metron>")
        XCTAssertEqual(metroid.timestamp, expectedDate)
        XCTAssertEqual(metroid.facets.count, expectedFacets.count)
        XCTAssertEqual(metroid.facets.filter(by: Significance.self), expectedFacets)
    }
}
