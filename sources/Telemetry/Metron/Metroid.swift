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

import Foundation

/// A ``Metron`` wrapper that includes any additional metadata captured during recording.
public struct Metroid<T> {

    /// The original ``Metron``.
    public let value: T

    /// The date the Metroid was created.
    public let timestamp: Date

    /// The final name of the metron after applying all ``Prefix`` facets followed by the ``Metron`` message.
    public let message: String

    /// The  facets associated with the metroid. Includes facets added after the ``Metron`` was created.
    public let facets: [Facet]

    /// Convenience getter for the metron's significance.
    public let significance: Significance

    init(metron: Metron, value: T, additionalFacets: [Facet], timestamp: Date) {

        self.value = value
        self.timestamp = timestamp

        // Prepend injected facets before metron's.
        var allFacets: [Facet] = additionalFacets
            + metron.facets

        // Add `Significance` if missing.
        self.significance = {

            if let significance = allFacets.significance {
                return significance
            }

            // Check if the facets array contains a `Failure`. If so, set significance to `error`. Else, `verbose`.
            let significance: Significance = allFacets.contains(type: Failure.self) ? .error : .verbose
            allFacets.insert(significance, at: 0)
            return significance
        }()

        // Resolve message by combining metron's message with prefix
        let message = metron.message
        let prefix = allFacets.prefix

        self.message = [prefix, message]
            .compactMap { $0 }          // remove nil values
            .joined(separator: " ")     // join strings with a space

        // Set the facets property after everything has been merged and appended
        self.facets = allFacets
    }
}

// MARK: - Public Initializers

extension Metroid where T: Metron {

    /// Convenience init to create a ``Metroid`` generic to its metron's type.
    public init(_ metron: T, additionalFacets: [Facet] = [], timestamp: Date = Date()) {
        self.init(
            metron: metron,
            value: metron,
            additionalFacets: additionalFacets,
            timestamp: timestamp
        )
    }
}

extension Metroid where T == Metron {

    /// Convenience init to create a ``Metroid`` generic to the ``Metron`` type.
    public init(_ metron: Metron, additionalFacets: [Facet] = [], timestamp: Date = Date()) {
        self.init(
            metron: metron,
            value: metron,
            additionalFacets: additionalFacets,
            timestamp: timestamp
        )
    }
}

// MARK: - CustomStringConvertible

extension Metroid: CustomStringConvertible {
    public var description: String {
        "Metroid<\(String(describing: type(of: value)))>: \(String(describing: value))"
    }
}
