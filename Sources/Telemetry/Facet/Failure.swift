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

import Foundation

/// Facet that indicates a failure with an `Error`.
///
/// A ``Failure`` is used to capture an `Error` associated with a metron.
/// The presence of a ``Failure`` does not necessarily mean the ``Significance`` level is that of an error or internal error.
/// For example a  metron with a ``Significance/warning`` facet might also have a ``Failure`` wrapping an `Error`, but it's just a warning.
public struct Failure: Facet {

    /// The `Error` for the ``Failure``.
    public let error: Error

    /// Creates a ``Failure`` instance from the specified parameters.
    ///
    /// - Parameters:
    /// - error: The `Error` for the failure.
    public init(_ error: Error) {
        self.error = error
    }
}

extension Failure: Equatable {
    public static func == (lhs: Failure, rhs: Failure) -> Bool {
        lhs.error as NSError == rhs.error as NSError
    }
}
