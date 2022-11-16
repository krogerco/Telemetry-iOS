// MIT License
//
// Copyright (c) 2020 The Kroger Co. All rights reserved.
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

import Telemetry
import Foundation
import Gauntlet
import XCTest

class MockTelemeterTestCase: XCTestCase {
    func testMockTelemeterInitializer() {
        // Given, When
        let telemeter = MockTelemeter()

        // Then
        XCTAssertIsEmpty(telemeter.metroids)
        XCTAssertIsEmpty(telemeter.metrons)
        XCTAssert(telemeter, is: Telemeter.self)
    }

    func testMockTelemeterRecording() {
        // Given
        let telemeter = MockTelemeter()

        // When
        telemeter.record(SomeMetron(), adding: [TestFacet.isEven])
        telemeter.record(TestMetron.that, adding: [OtherFacet.blah])

        // Then
        XCTAssertEqual(telemeter.metroids.count, 2) {
            let firstMetroid = telemeter.metroids[0]

            XCTAssertEqual(firstMetroid.facets.first(ofType: TestFacet.self), .isEven)
            XCTAssert(firstMetroid.value, is: SomeMetron.self)

            let secondMetroid = telemeter.metroids[1]

            XCTAssertEqual(secondMetroid.facets.first(ofType: OtherFacet.self), .blah)
            XCTAssert(secondMetroid.value, is: TestMetron.self)
        }

        XCTAssertEqual(telemeter.metrons.count, 2) {
            XCTAssert(telemeter.metrons[0], is: SomeMetron.self)
            XCTAssert(telemeter.metrons[1], is: TestMetron.self)
        }
    }

    func testMetronsOfType() {
        // Given
        let telemeter = MockTelemeter()

        // When
        telemeter.record(SomeMetron())
        telemeter.record(TestMetron.this)
        telemeter.record(SomeMetron())
        telemeter.record(TestMetron.that)
        telemeter.record(SomeMetron())

        // Then
        XCTAssertEqual(telemeter.metrons(ofType: TestMetron.self), [.this, .that])
    }

    /// Unwraps the most recent `Metron` recorded by this telemeter.
    func testLastRecordedMetron() {

        struct MockMetron: Metron {
            let message: String
        }

        // Given
        let telemeter = MockTelemeter()
        let expectedMessage = "This is the expected message."

        // When
        telemeter.record(MockMetron(message: "Hello"))
        telemeter.record(MockMetron(message: "World"))
        telemeter.record(MockMetron(message: expectedMessage))

        // Then
        XCTAssertNotNil(telemeter.lastRecordedMetron) { metron in
            XCTAssertEqual(metron.message, expectedMessage)
        }
    }

    /// Clears all recorded metroids.
    func testReset() {

        struct MockMetron: Metron {
            let message: String = "Mock Metron"
        }

        // Given
        let telemeter = MockTelemeter()

        // When
        telemeter.record(MockMetron())
        telemeter.record(MockMetron())
        XCTAssertEqual(telemeter.metroids.count, 2) // double check count isn't already 0

        telemeter.reset() // clear recorded metrons

        // Then
        XCTAssertEqual(telemeter.metroids.count, 0)
    }

    /// Total number of times this telemeter has recorded a metron.
    func testRecordCount() {

        struct MockMetron: Metron {
            let message: String = "Mock Metron"
        }

        // Given
        let telemeter = MockTelemeter()
        let expectedCount = 3

        // When
        telemeter.record(MockMetron())
        telemeter.record(MockMetron())
        telemeter.record(MockMetron())

        // Then
        XCTAssertEqual(telemeter.recordCount, expectedCount)
    }
}
