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

class FacetedTelemeterTestCase: XCTestCase {

    // MARK: - Facets

    struct RecordSiteFacet: Facet {}
    struct TelemeterFacet: Facet {}
    struct ParentTelemeterFacet: Facet {}

    // MARK: - Tests

    func testFacetedTelemeter() {
        // Given
        let parentTelemeter = MockTelemeter()

        // When
        let facetedTelemeter = parentTelemeter.telemeter(with: [TelemeterFacet()])
        facetedTelemeter.record(SomeMetron(), adding: [RecordSiteFacet()])

        // Then
        XCTAssert(facetedTelemeter, is: FacetedTelemeter.self)
        XCTAssertNotNil(parentTelemeter.metroids.first) { metroid in
            XCTAssert(metroid.facets.contains(type: TelemeterFacet.self))
            XCTAssert(metroid.facets.contains(type: RecordSiteFacet.self))
        }
    }

    func testFacetedTelemeterWithFacetedTelemeterAsParent() {
        // Given
        let parentTelemeter = MockTelemeter()
        let parentFacetedTelemeter = parentTelemeter.telemeter(with: [ParentTelemeterFacet()])

        // When
        let facetedTelemeter = parentFacetedTelemeter.telemeter(with: [TelemeterFacet()])
        facetedTelemeter.record(SomeMetron(), adding: [RecordSiteFacet()])

        // Then
        XCTAssert(facetedTelemeter, is: FacetedTelemeter.self) { telemeter in
            XCTAssert(telemeter.parent, is: MockTelemeter.self)
        }

        XCTAssertNotNil(parentTelemeter.metroids.first) { metroid in
            XCTAssert(metroid.facets.contains(type: RecordSiteFacet.self))
            XCTAssert(metroid.facets.contains(type: ParentTelemeterFacet.self))
            XCTAssert(metroid.facets.contains(type: TelemeterFacet.self))
        }
    }

    func testFacetHierarchy() {

        enum BreadCrumb: Facet, Equatable {
            case A, B, C // swiftlint:disable:this identifier_name
            case additional
            case metron
        }

        // Given
        let parentTelemeter = MockTelemeter()
        let telemeter = parentTelemeter
                .telemeter(with: [BreadCrumb.A])
                .telemeter(with: [BreadCrumb.B])
                .telemeter(with: [BreadCrumb.C])
        let additionalFacets = [BreadCrumb.additional]
        let facets = [BreadCrumb.metron]

        let expectedFacets: [BreadCrumb] = [.C, .B, .A, .additional, .metron]

        // When
        telemeter.record(SomeMetron(facets: facets), adding: additionalFacets)

        // Then
        XCTAssert(telemeter, is: FacetedTelemeter.self)

        XCTAssertNotNil(parentTelemeter.metroids.first) { metroid in
            let recordedFacets = metroid.facets.filter(by: BreadCrumb.self)
            XCTAssertEqual(recordedFacets, expectedFacets)
        }
    }
}
