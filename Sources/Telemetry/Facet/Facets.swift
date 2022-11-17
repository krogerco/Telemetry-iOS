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

public enum Facets: Facet {
    public typealias Significance = Telemetry.Significance
    public typealias Prefix = Telemetry.Prefix
    public typealias File = Telemetry.File
    public typealias Failure = Telemetry.Failure
}

/// Significance Convenience Vars
/// 
/// This is what makes code like `let facets: [Facet] = [.debug]` work.
extension Facet where Self == Facets {

    /// Convenience accessor for ``Significance/debug``.
    ///
    /// This metron is considered debug level information.
    public static var debug: Significance { Significance.debug }

    /// Convenience accessor for ``Significance/verbose``.
    ///
    /// This metron has a verbose (or unspecified) significance.
    /// Generally will be filtered out to human facing relays.
    public static var verbose: Significance { Significance.verbose }

    /// Convenience accessor for ``Significance/informational``.
    ///
    /// This metron has information that is generally useful.
    public static var informational: Significance { Significance.informational }

    /// Convenience accessor for ``Significance/warning``.
    ///
    /// This metron represents a warning.
    public static var warning: Significance { Significance.warning }

    /// Convenience accessor for ``Significance/error``.
    ///
    /// This metron represents an error.
    public static var error: Significance { Significance.error }

    /// Convenience accessor for ``Significance/internalError``.
    ///
    /// This metron represent an internal error (e.g. a `guard` failure).
    public static var internalError: Significance { Significance.internalError }
}
