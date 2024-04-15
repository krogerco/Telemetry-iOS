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

import Foundation

/// A telemeter that holds on to all metrons recorded to it. This is intended for use in Unit Tests so that Telemetry records that occur
/// in code being tested can be validated as part of the tests.
public final class MockTelemeter: Telemeter, @unchecked Sendable {
    private let lock = NSRecursiveLock()

    /// All ``Metron``s that have been recorded to this telemeter.
    public var metrons: [Metron] { metroids.map { $0.value } }

    /// All ``Metroid``s that have been recorded to this telemeter.
    public private(set) var metroids: [Metroid<Metron>] {
        get {
            lock.lock(); defer { lock.unlock() }
            return _metroids
        }

        set {
            lock.lock(); defer { lock.unlock() }
            _metroids = newValue
        }
    }

    // The storage for the locked `metroids` property. This should not be accessed directly.
    private var _metroids: [Metroid<Metron>] = []

    /// Creates a ``MockTelemeter`` instance.
    public init() { }

    public func record(_ metron: Metron, adding facets: [Facet]) {
        metroids.append(Metroid<Metron>(metron: metron, value: metron, additionalFacets: facets, timestamp: Date()))
    }

    /// Returns all ``Metron``s of a given type that have been recorded to this telemeter.
    ///
    /// - Parameter type: The Type of ``Metron`` to filter on.
    /// - Returns:        All ``Metron``s of the specified type that have been recorded to this telemeter.
    public func metrons<T: Metron>(ofType type: T.Type) -> [T] {
        metroids.compactMap { $0.value as? T }
    }

    /// Unwraps the most recent ``Metron`` recorded by this telemeter.
    public var lastRecordedMetron: Metron? {
        metroids.last?.value
    }

    /// Clears all recorded metroids.
    public func reset() {
        metroids = []
    }

    /// Total number of times this telemeter has recorded a metron.
    public var recordCount: Int {
        metroids.count
    }
}
