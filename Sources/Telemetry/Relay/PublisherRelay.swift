// MIT License
//
// Copyright (c) 2022 The Kroger Co. All rights reserved.
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

import Combine
import Foundation

/// A Relay that provides a Metron Combine publisher.
public class PublisherRelay: Relay {

    var internalPublisher = PassthroughSubject<any Metron, Never>()

    /// Creates a ``PublisherRelay``.
    public init() {}

    public func process(metroid: Metroid<Metron>) {
        internalPublisher.send(metroid.value)
    }

    /// Publishes received metrons converted to the specified type, if possible
    /// .
    /// - Parameter type: The type to filter on and publish.
    ///
    /// - Returns: An `AnyPublisher` with the given output type.
    /// 
    /// - Note: Values are published on an unspecified queue.
    public func publisher<T>(of type: T.Type) -> AnyPublisher<T, Never> {
        internalPublisher
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }
}
