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

/// A ``LogMetron`` is the ``Metron`` created when `debugLog` or `internalError` is called with a `String`.
public struct LogMetron: Metron {
    /// The message to be logged.
    public let message: String

    /// Facets associated with the message.
    public let facets: [Facet]

    /// Creates a ``LogMetron`` instance from the specified parameters.
    ///
    /// - Parameters:
    ///   - message: The message to be logged.
    public init(message: String, facets: [Facet] = []) {
        self.message = message
        self.facets = facets
    }

    /// Creates a ``LogMetron`` instance from the specified parameters.
    ///
    /// - Parameters:
    ///   - message:    The message to be logged.
    ///   - error:      The error to associate with the message.
    public init(message: String, error: Error) {
        self.message = message
        self.facets = [Failure(error)]
    }
}
