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

@testable import Telemetry
import Gauntlet
import XCTest

class FailureTestCase: XCTestCase {

    func testFailureInitWithCustomError() {
        // Given, When
        let facet = Failure(SomeError())

        // Then
        XCTAssert(facet.error, is: SomeError.self)
    }

    func testFailureEquatable() {

        enum SampleError: Error {
            case one, two
        }

        // Given, When
        let failure1 = Failure(SampleError.one)
        let failure2 = Failure(SampleError.two)
        let failure3 = Failure(NSError(domain: "test", code: 42, userInfo: nil))

        // Then
        XCTAssertEqual(failure1, failure1)
        XCTAssertEqual(failure2, failure2)
        XCTAssertEqual(failure3, failure3)

        XCTAssertNotEqual(failure1, failure2)
        XCTAssertNotEqual(failure1, failure3)
        XCTAssertNotEqual(failure2, failure3)
    }

    func testFacetConformance() {
        // Given
        let failure = Failure(SomeError())

        // When
        let metron = SomeMetron(facets: [failure])

        // Then
        XCTAssert(metron.facets.contains(type: Failure.self))
    }
}
