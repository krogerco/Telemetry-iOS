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

class StandardTelemeterTestCase: XCTestCase {

    func testInitialization() {

        // Given
        let relay = MockRelay<Metron>()

        // When
        let telemeter = StandardTelemeter()
        telemeter.add(relay: relay)

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)
        XCTAssert(telemeter.relays.first?.value, is: RelayBox<MockRelay<Metron>>.self)
    }

    func testRecord() {
        // Given
        let relay = MockRelay<Metron>()
        let telemeter = StandardTelemeter()
        let event = SomeMetron()
        let facet = TestFacet.other

        telemeter.add(relay: relay)

        // When
        telemeter.record(event, adding: [facet])

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)

        XCTAssertEqual(relay.labelOfQueueProcessWasCalledOn, telemeter.queue.label)
        XCTAssertEqual(relay.processedMetroids.first?.facets.first(ofType: TestFacet.self), facet)
    }

    func testThatRelayCanBeAdded() {

        // Given
        let telemeter = StandardTelemeter()
        let relay = MockRelay<Metron>()

        // When
        telemeter.add(relay: relay)
        telemeter.add(relay: ConsoleRelay())

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)

        XCTAssertEqual(telemeter.relays.count, 2)
    }

    func testProcessingThatIsHandledByRelay() {
        // Given
        let telemeter = StandardTelemeter()
        let relay = MockRelay<Metron>()

        // When
        telemeter.add(relay: relay)
        telemeter.record(MessageMetron(message: "A very important message."))

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)
        XCTAssertEqual(relay.processedMetroids.count, 1)
    }

    func testThatMultipleRelaysCanProcessTheSameEvent() {
        // Given
        let telemeter = StandardTelemeter()
        let firstRelay = MockRelay<MessageMetron>()
        let secondRelay = MockRelay<Metron>()

        // When
        telemeter.add(relay: firstRelay)
        telemeter.add(relay: secondRelay)
        telemeter.record(MessageMetron(message: "A very important message."))

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)
        XCTAssertEqual(firstRelay.processedMetroids.count, 1)
        XCTAssertEqual(secondRelay.processedMetroids.count, 1)
    }

    func testThatRelaysWithDifferentGenericTypesCanBeAdded() {

        enum SomeTypeThatIsDecidedlyNotAMetron {}

        // Given
        let telemeter = StandardTelemeter()
        let firstRelay = MockRelay<MessageMetron>()
        let secondRelay = MockRelay<SomeMetron>()
        let thirdRelay = MockRelay<Metron>()
        let fourthRelay = MockRelay<SomeTypeThatIsDecidedlyNotAMetron>()

        // When
        XCTAssertEqual(telemeter.relays.count, 0)

        telemeter.add(relay: firstRelay)
        telemeter.add(relay: secondRelay)
        telemeter.add(relay: thirdRelay)
        telemeter.add(relay: fourthRelay)

        // Then
        waitFor(queue: telemeter.queue, timeout: 0.2)

        XCTAssertEqual(telemeter.relays.count, 4)
    }
}

// MARK: - Helper Types

private struct VeryBadError: Metron {
    let message: String = "A Very Bad Error"
    let whatWentWrong: String
}

private struct MessageMetron: Metron, CustomStringConvertible {
    let message: String
    var description: String { message }
}

private class MockRelay<T>: Relay {

    private(set) var labelOfQueueProcessWasCalledOn: String?
    private(set) var processedMetroids: [Metroid<T>] = []

    func process(metroid: Metroid<T>) {
        labelOfQueueProcessWasCalledOn = DispatchQueue.currentQueueLabel
        processedMetroids.append(metroid)
    }
}
