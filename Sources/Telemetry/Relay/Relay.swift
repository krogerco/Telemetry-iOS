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

/// A type that receives ``Metron``s from a telemeter and relays them to a destination, such as the debug console or a web service.
public protocol Relay: Sendable {

    /// The ``Metron`` type this relay can process. Use ``Metron`` to receive all metrons.
    associatedtype MetronType

    /// Called by the telemeter to process a metron that was received.
    ///
    /// This is the main entry point for a relay, where it does whatever it needs to do with the incoming ``Metroid``.
    ///
    /// For example, the ``ConsoleRelay`` prints the message to the Xcode console.
    /// A relay for a 3rd party service might pass along the message and facet data to an SDK.
    ///
    /// - Parameter metroid: A metroid containing the original metron that was recorded along with additional metadata.
    func process(metroid: Metroid<MetronType>)
}

public extension Relay {
    func process(metron: Metron, with additionalFacets: [Facet], dateRecorded: Date) {

        guard let value = metron as? MetronType else {
            return
        }

        let metroid = Metroid<MetronType>(
            metron: metron,
            value: value,
            additionalFacets: additionalFacets,
            timestamp: dateRecorded
        )

        process(metroid: metroid)
    }
}
