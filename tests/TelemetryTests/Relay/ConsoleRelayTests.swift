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
import os
import XCTest
import Gauntlet

class ConsoleRelayTestCase: XCTestCase {

    struct MockMetron: Metron {
        let message: String
        let facets: [Facet]
    }

    // MARK: - Tests

    func testProcessMetroidWithoutError() {

        // Given
        var printedString: String?

        let printer: Printer = { string in
            printedString = string
        }

        let significance = Significance.warning
        let metroid = Metroid<Metron>(MockMetron(message: "Testing Process", facets: [significance]))
        let relay = ConsoleRelay(allowedSignificances: Significance.allCases, printer: printer)
        let dateString = relay.dateFormatter.string(from: metroid.timestamp)
        let expectedString = "\(significance.icon) \(dateString) – \(metroid.message)"

        // When
        relay.process(metroid: metroid)

        // Then
        XCTAssertIsNotEmpty(dateString)
        XCTAssertEqual(printedString, expectedString)
    }

    func testProcessMetroidWithError() {

        // Given
        var printedString: String?

        let printer: Printer = { string in
            printedString = string
        }

        let error = SomeError()
        let significance = Significance.informational
        let metroid = Metroid<Metron>(MockMetron(message: "Testing Process", facets: [significance, Failure(error)]))
        let relay = ConsoleRelay(allowedSignificances: Significance.allCases, printer: printer)
        let dateString = relay.dateFormatter.string(from: metroid.timestamp)
        let expectedString = "\(significance.icon) \(dateString) – \(metroid.message) ‼️ \(error)"

        // When
        relay.process(metroid: metroid)

        // Then
        XCTAssertIsNotEmpty(dateString)
        XCTAssertEqual(printedString, expectedString)
    }

    func testRenderStringWithoutError() {

        // Given
        let relay = ConsoleRelay()

        let date = relay.dateFormatter.date(from: "01:46:40.1830")! // swiftlint:disable:this force_unwrapping
        let message: (Significance) -> String = {
            "mock message for case .\(String(describing: $0))"
        }

        let expectedStrings: [String] = [
            "🟣 01:46:40.1830 – mock message for case .debug",
            "🔵 01:46:40.1830 – mock message for case .verbose",
            "🟢 01:46:40.1830 – mock message for case .informational",
            "🟡 01:46:40.1830 – mock message for case .warning",
            "🔴 01:46:40.1830 – mock message for case .error",
            "‼️ 01:46:40.1830 – mock message for case .internalError"
        ]

        // When
        let renderedStrings = Significance.allCases.map {
            relay.render(significance: $0, message: message($0), timestamp: date, error: nil)
        }

        // Then
        XCTAssertEqual(renderedStrings, expectedStrings)
    }

    func testRenderStringWithError() {

        struct MockError: Error, CustomStringConvertible {
            let description: String = "This is a mock error."
        }

        // Given
        let relay = ConsoleRelay()

        let date = relay.dateFormatter.date(from: "19:46:40.1830")! // swiftlint:disable:this force_unwrapping
        let message: (Significance) -> String = {
            "mock message for case .\(String(describing: $0))"
        }

        let expectedStrings: [String] = [
            "🟣 19:46:40.1830 – mock message for case .debug ‼️ This is a mock error.",
            "🔵 19:46:40.1830 – mock message for case .verbose ‼️ This is a mock error.",
            "🟢 19:46:40.1830 – mock message for case .informational ‼️ This is a mock error.",
            "🟡 19:46:40.1830 – mock message for case .warning ‼️ This is a mock error.",
            "🔴 19:46:40.1830 – mock message for case .error ‼️ This is a mock error.",
            "‼️ 19:46:40.1830 – mock message for case .internalError ‼️ This is a mock error."
        ]

        // When
        let renderedStrings = Significance.allCases.map {
            relay.render(significance: $0, message: message($0), timestamp: date, error: MockError())
        }

        // Then
        XCTAssertEqual(renderedStrings, expectedStrings)
    }

    func testSignificanceFilter() {

        // Given
        var capturedStrings: [String] = []

        let printer: Printer = { string in
            capturedStrings.append(string)
        }

        let allowedSignificance: [Significance] = [.warning, .error]
        let relay = ConsoleRelay(allowedSignificances: allowedSignificance, printer: printer)

        // When
        Significance.allCases.forEach { signifiance in
            let metroid = Metroid<Metron>(MockMetron(message: String(describing: signifiance), facets: [signifiance]))
            relay.process(metroid: metroid)
        }

        // Then
        XCTAssertEqual(capturedStrings.count, 2) {
            XCTAssert(capturedStrings[0], contains: "warning")
            XCTAssert(capturedStrings[1], contains: "error")
        }
    }

    func testPrintToConsole() {

        let relay = ConsoleRelay(allowedSignificances: Significance.allCases)

        Significance.allCases.forEach { significance in
            let metron = MockMetron(message: ".\(significance) spot test", facets: [significance, Failure(SomeError())])
            let metroid = Metroid<Metron>(metron)
            relay.process(metroid: metroid)
        }

        // Can't test anything, just hope these show up in the console.
    }
}
