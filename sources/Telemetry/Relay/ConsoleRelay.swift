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

/// Pre-built ``Relay`` for printing ``Metron``s to the console.
/// By default, only logs metrons of informational, warning, exceptional, or internal error significance.
public class ConsoleRelay: Relay {

    /// Date formatter used to format dates.
    public let dateFormatter: DateFormatter

    let print: Printer
    let allowedSignificances: [Significance]

    init(allowedSignificances: [Significance],
         printer: @escaping Printer) {

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm:ss.SSSS")
        self.dateFormatter = formatter
        self.allowedSignificances = allowedSignificances
        self.print = printer
    }

    /// Creates a ``ConsoleRelay`` instance.
    ///
    /// - Parameter allowedSignificances: Array of significances used to filter output.
    public convenience init(allowedSignificances: [Significance] = [.internalError, .error, .warning, .informational]) {
        self.init(allowedSignificances: allowedSignificances, printer: defaultPrinter)
    }

    public func process(metroid: Metroid<Metron>) {
        #if DEBUG

        guard allowedSignificances.contains(metroid.significance) else { return }

        let message = render(
            significance: metroid.significance,
            message: metroid.message,
            timestamp: metroid.timestamp,
            error: metroid.facets.first(ofType: Failure.self)?.error
        )

        self.print(message)
        #endif
    }

    func render(significance: Significance, message: String, timestamp: Date, error: Error?) -> String {

        let timeString = dateFormatter.string(from: timestamp)

        let suffix: String = {
            if let error = error {
                return " ‼️ \(error)"
            }
            return ""
        }()

        return "\(significance.icon) \(timeString) – \(message)\(suffix)"
    }
}

extension Significance {
    var icon: String {
        switch self {
        case .debug:         return "🟣"
        case .verbose:       return "🔵"
        case .informational: return "🟢"
        case .warning:       return "🟡"
        case .error:         return "🔴"
        case .internalError: return "‼️"
        }
    }
}
