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

import XCTest
import Gauntlet
@testable import Telemetry

class RelayBoxTests: XCTestCase {

    class MockRelay<T>: Relay {

        var captured: [Metroid<T>] = []

        func process(metroid: Metroid<T>) {
            captured.append(metroid)
        }
    }

    struct MockFacet: Facet {}

    /// Test that `RelayBoxGeneric` filters out `Metrons` that don't match the accepted type.

    func testRelayBoxProcess() {

        struct GoodMetron: Metron, CustomStringConvertible {
            let message: String = "A good metron."
            var description: String = "Good Metron"
        }
        struct BadMetron: Metron {
            let message: String = "A bad metron."
        }

        // Given
        let date = Date()
        let relay = MockRelay<CustomStringConvertible>()
        let box = RelayBox(relay: relay)

        let acceptedMetron = GoodMetron()
        let ignoredMetron = BadMetron()

        let additionalFacets = [MockFacet()]

        // When
        box.process(metron: acceptedMetron, with: additionalFacets, dateRecorded: date)
        box.process(metron: ignoredMetron, with: additionalFacets, dateRecorded: date)

        // Then
        XCTAssertEqual(relay.captured.count, 1)

        XCTAssertEqual(relay.captured[0].value.description, "Good Metron")
        XCTAssertTrue(relay.captured[0].facets.contains(type: MockFacet.self), "Box did not passthrough additional facets.")
        XCTAssertEqual(relay.captured[0].timestamp, date, "Box did bot passthrough the date recorded.")
    }

    /// Test that `RelayBoxMetron` accepts all `Metrons` of any type.
    func testMetronRelayBoxProcess() {

        // Given
        let date = Date()
        let relay = MockRelay<Metron>()
        let box = RelayBox(relay: relay)

        let metronA = SomeMetron()
        let metronB = TestMetron.that

        let expectedMetroidsCaptured = 2
        let additionalFacets = [MockFacet()]

        // When
        box.process(metron: metronA, with: additionalFacets, dateRecorded: date)
        box.process(metron: metronB, with: additionalFacets, dateRecorded: date)

        // Then
        XCTAssertEqual(expectedMetroidsCaptured, relay.captured.count)

        relay.captured.forEach { metroid in
            XCTAssertTrue(metroid.facets.contains(type: MockFacet.self), "Box did not passthrough additional facets.")
            XCTAssertEqual(metroid.timestamp, date, "Box did bot passthrough the date recorded.")
        }
    }
}
