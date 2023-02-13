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

import Telemetry
import Gauntlet
import XCTest

class TelemeterTests: XCTestCase {

    var telemeter = MockTelemeter()

    override func setUp() {
        super.setUp()

        telemeter = MockTelemeter()
    }

    func testLogMessage() {
        // Given, When
        telemeter.debugLog("Hello")

        // Then
        XCTAssertEqual(telemeter.metroids.count, 1) {
            let metroid = telemeter.metroids[0]
            XCTAssertEqual(metroid.facets.count, 2)
            XCTAssertEqual(metroid.message, "Hello")
            XCTAssertEqual(metroid.facets.first(ofType: Significance.self), .debug)
        }
    }

    func testLogMessageError() {
        // Given, When
        telemeter.debugLog("Hello", error: SomeError())

        // Then
        XCTAssertEqual(telemeter.metroids.count, 1) {
            let metroid = telemeter.metroids[0]
            XCTAssertEqual(metroid.facets.count, 3)
            XCTAssertEqual(metroid.message, "Hello")
            XCTAssertEqual(metroid.facets.first(ofType: Significance.self), .debug)
            XCTAssert(metroid.facets.first(ofType: Failure.self)?.error, is: SomeError.self)
        }
    }

    func testLogInternalError() {
        // Given, When
        telemeter.internalError("Hello", error: SomeError())

        // Then
        XCTAssertEqual(telemeter.metroids.count, 1) {
            let metroid = telemeter.metroids[0]
            XCTAssertEqual(metroid.facets.count, 3)
            XCTAssertEqual(metroid.message, "Hello")
            XCTAssertEqual(metroid.facets.first(ofType: Significance.self), .internalError)
            XCTAssert(metroid.facets.first(ofType: Failure.self)?.error, is: SomeError.self)
        }
    }

    func testLogInternalErrorWithNilError() {
        // Given
        let expectedFileName = "TelemeterTests.swift"
        let expectedLineNumber: UInt = #line + 3

        // When
        telemeter.internalError("Hello")

        // Then
        XCTAssertEqual(telemeter.metroids.count, 1) {
            let metroid = telemeter.metroids[0]
            XCTAssertEqual(metroid.facets.count, 2)
            XCTAssertEqual(metroid.message, "Hello")
            XCTAssertEqual(metroid.facets.first(ofType: Significance.self), .internalError)

            XCTAssertNotNil(metroid.facets.first(ofType: File.self)) { file in
                XCTAssert(file.name, contains: expectedFileName)
                XCTAssertEqual(file.line, expectedLineNumber)
            }
        }
    }

    func testRecordAddsFileFacet() {
        // Given
        let expectedFileName = "TelemeterTests.swift"
        let expectedLineNumber: UInt = #line + 3

        // When
        telemeter.record(SomeMetron())

        // Then
        XCTAssertEqual(telemeter.metroids.count, 1) {
            let metroid = telemeter.metroids[0]
            XCTAssertNotNil(metroid.facets.first(ofType: File.self)) { file in
                XCTAssert(file.name, contains: expectedFileName)
                XCTAssertEqual(file.line, expectedLineNumber)
            }
        }
    }
}

private class MockRelay: Relay {

    private(set) var processedMetroid: Metroid<Metron>?
    var expect: XCTestExpectation?

    func process(metroid: Metroid<Metron>) {
        processedMetroid = metroid
        DispatchQueue.main.async {
            self.expect?.fulfill()
        }
    }
}
