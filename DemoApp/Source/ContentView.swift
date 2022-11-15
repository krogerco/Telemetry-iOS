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

import SwiftUI
import Telemetry

struct ContentView: View {

    let telemeter: Telemeter = {

        // Setup ConsoleRelay to accept all significance levels
        let consoleRelay = ConsoleRelay(allowedSignificances: Significance.allCases)

        // Create a `StandardTelemeter` and add all relays to it.
        let telemeter = StandardTelemeter()
        telemeter.add(relay: AnalyticsRelay())
        telemeter.add(relay: CatchAllRelay())
        telemeter.add(relay: consoleRelay)

        return telemeter
    }()

    var body: some View {

        List {

            Button("Red") {
                // When a button is tapped, record the appropriate metron to the telemeter and it will be processed by each relay.
                telemeter.record(AnalyticsEvent.tappedRedButton)
            }
            .foregroundColor(.red)

            Button("Blue") {
                telemeter.record(AnalyticsEvent.tappedBlueButton)
            }
            .foregroundColor(.blue)

            Button("Green") {
                telemeter.record(AnalyticsEvent.tappedGreenButton)
            }
            .foregroundColor(.green)

            Button("Yellow") {
                telemeter.record(OneOffEvent())
            }
            .foregroundColor(.yellow)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
