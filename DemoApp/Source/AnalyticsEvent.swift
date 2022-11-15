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
import Telemetry

enum AnalyticsEvent: Metron {
    case tappedRedButton
    case tappedBlueButton
    case tappedGreenButton

    var message: String {
        switch self {
        case .tappedRedButton:   return "Tapped Red Button!"
        case .tappedBlueButton:  return "Tapped Blue Button!"
        case .tappedGreenButton: return "Tapped Green Button!"
        }
    }

    var facets: [Facet] {
        switch self {
        case .tappedRedButton:   return [.error]
        case .tappedBlueButton:  return [.informational]
        case .tappedGreenButton: return [.verbose]
        }
    }
}

/// Metrons don't always have to be enums. Sometimes a struct will do.
struct OneOffEvent: Metron {
    let message = "Tapped Yellow Button"
    let facets: [Facet] = [.informational]
}
