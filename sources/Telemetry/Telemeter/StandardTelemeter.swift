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

/// A ``Telemeter`` implementation which forwards metrons to ``Relay``s.
open class StandardTelemeter: Telemeter {

    /// The application wide shared ``StandardTelemeter``.
    /// While singletons are generally avoided, it's important for there to
    /// always be a telemeter available that actually goes somewhere.
    ///
    /// Who should use this?
    /// - The application should configure this at launch and inject into rest of app.
    /// - Modules should default to this telemeter on launch until reconfigured.
    /// - Code that cannot support telemeter injection should use this telemeter.
    ///
    /// Otherwise, code should not directly reference the main telemeter.
    public static let shared = StandardTelemeter()

    /// The queue on which all relays will be called.
    public let queue = DispatchQueue(label: "com.kroger.telemetry.standardtelemeter")

    var relays: [ObjectIdentifier: AnyRelay] = [:]

    /// Creates a ``StandardTelemeter``.
    public init() {}

    /// Add a ``Relay`` to the telemeter.
    ///
    /// - Parameters:
    ///   - relay: Relay to add.
    public func add<T>(relay: T) where T: Relay {
        append(
            relay: RelayBox(relay: relay),
            identifier: ObjectIdentifier(T.self),
            prettyName: String(describing: T.self)
        )
    }

    /// Records a ``Metron`` along with the provided ``Facet``s.
    ///
    /// - Parameters:
    ///   - metron: The ``Metron`` to record.
    ///   - facets: Additional ``Facet``s to capture with the ``Metron``.
    public func record(_ metron: Metron, adding facets: [Facet]) {

        let date = Date()

        queue.async {
            self.relays.values.forEach { relay in
                relay.process(metron: metron, with: facets, dateRecorded: date)
            }
        }
    }

    func append<T: AnyRelay>(relay: T, identifier: ObjectIdentifier, prettyName: String) {

        queue.async {

            guard self.relays.keys.contains(identifier) == false else {
                assertionFailure("Cannot add another Relay with type \"\(prettyName)\".")
                return
            }

            self.relays[identifier] = relay
        }

    }
}

private let mainTelemeter = StandardTelemeter()
