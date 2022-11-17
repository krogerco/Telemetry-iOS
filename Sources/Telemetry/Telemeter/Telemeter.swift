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
import os

/// A type that can record ``Metron``s.
public protocol Telemeter {
    /// Records a ``Metron`` along with the provided ``Facet``s to the receiving ``Telemeter``.
    ///
    /// - Parameters:
    ///   - metron: The `Metron` to record.
    ///   - facets: Additional `Facet`s to capture with the `Metron`.
    func record(_ metron: Metron, adding facets: [Facet])
}

// MARK: - Record Convenience

extension Telemeter {
    /// Records a ``Metron`` to the receiving ``Telemeter``.
    ///
    /// - Parameter metron: The `Metron` to record.
    public func record(_ metron: Metron) {
        record(metron, adding: [])
    }
}

// MARK: - Logging Convenience

extension Telemeter {
    /// Records a string as a debug message.
    ///
    /// - Parameters:
    ///   - message:    Message to record.
    ///   - error:      Error to record (Optional). This will add the ``Significance/debug`` facet.
    public func debugLog(_ message: String, error: Error? = nil, file: StaticString = #fileID, line: UInt = #line) {
        log(message: message, error: error, significance: .debug, file: file, line: line)
    }

    /// Records a string as an internal error.
    ///
    /// - Parameters:
    ///   - message:    Message to record.
    ///   - error:      Error to record (Optional). This will add the ``Significance/internalError`` facet.
    public func internalError(_ message: String, error: Error? = nil, file: StaticString = #fileID, line: UInt = #line) {
        log(message: message, error: error, significance: .internalError, file: file, line: line)
    }

    func log(
        message: String,
        error: Error? = nil,
        significance: Significance = .debug,
        file: StaticString = #fileID,
        line: UInt = #line)
    {
        var facets: [Facet] = [
            File(name: file, line: line),
            significance
        ]

        if let error = error {
            facets.append(Failure(error))
        }

        let metron = LogMetron(message: message, facets: facets)

        record(metron)
    }
}

// MARK: - Facets

extension Telemeter {

    /// Creates a new ``Telemeter`` that will automatically attach the provided facets to each ``Metron`` recorded.
    ///
    /// - Parameter facets:     The ``Facet``s to attach to recorded ``Metron``s.
    ///                         In the event of duplicate Facet types in the array, the last Facet wins.
    ///
    /// - Returns:              A new `Telemeter` instance.
    public func telemeter(with facets: [Facet]) -> Telemeter {
        FacetedTelemeter(parent: self, facets: facets)
    }
}
