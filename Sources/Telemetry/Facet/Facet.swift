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

/// A  piece of metadata that is attached to a ``Metron``.
///
/// A ``Facet`` may be provided by the ``Metron`` itself, or may be attached to a ``Metron`` at the time of recording.
public protocol Facet {}

// MARK: - Facet Type Lookup

extension Array where Element == Facet {

    /// Convenience accessor for the first ``Significance`` facet, if available.
    public var significance: Significance? {
        self.first(ofType: Significance.self)
    }

    /// Convenience accessor that concats all ``Prefix`` facets, separated by a space.
    public var prefix: String? {

        let prefixes = self.filter(by: Prefix.self)

        guard prefixes.isEmpty == false else {
            return nil
        }

        return prefixes
            .map(\.value)
            .joined(separator: " ")
    }
}

// MARK: - Facet Type Lookup

extension Array where Element == Facet {

    /// Determine if the array contains a certain kind of facet type.
    ///
    /// - Parameter type: ``Facet`` type to search for.
    ///
    /// - Returns: `true` if type is found.
    public func contains<T: Facet>(type: T.Type) -> Bool {
        self.first { $0 is T } != nil // swiftlint:disable:this contains_over_first_not_nil
    }

    /// Get the highest precedence ``Facet`` for the specified type.
    ///
    /// - Parameter type: ``Facet`` type to search for.
    ///
    /// - Returns: Optional ``Facet`` value.
    public func first<T: Facet>(ofType: T.Type) -> T? {
        self.first { $0 is T } as? T
    }

    /// Filters facets to the specified type, preserving order.
    ///
    /// - Parameter type: Facet type to filter by.
    ///
    /// - Returns: Array of facets of the specified type, if any.
    public func filter<T: Facet>(by: T.Type) -> [T] { // swiftlint:disable:this identifier_name
        self.filter { $0 is T }
            .compactMap { $0 as? T }
    }

}

extension Array where Element == Facet {

    /// Determine if the array contains a specific facet value.
    ///
    /// - Parameter type: Facet type to search for.
    ///
    /// - Returns: true if facet is found.
    public func contains<T: Facet>(_ facet: T) -> Bool where T: Equatable {
        for element in self where element is T {
            if let lhs = element as? T, lhs == facet {
                return true
            }
        }
        return false
    }

    /// Determine if the array contains any of the facet values specified.
    ///
    /// - Parameter type: Facets to search for.
    ///
    /// - Returns: true if any facet is found.
    public func containsAny<T: Facet>(_ facets: [T]) -> Bool where T: Equatable {
        for element in self where element is T {
            if let lhs = element as? T, facets.contains(lhs) {
                return true
            }
        }
        return false
    }
}
