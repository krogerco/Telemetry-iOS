# Telemetry for iOS

Telemetry is an easy-to-use unified pipeline for engineering logging and business analytics. 

Applications and frameworks want to record data corresponding to both user initiated and internal events. Sometimes this is for engineering purposes (debugging and instrumentation) and sometimes this is for business analytics. In many cases, these events are overlapping. When the event happens, we want to collect engineering information AND business analytics.

Telemetry makes it easy to define a single event to be recorded and interpreted correctly as it arrives at different destinations. 

Abstracting your engineering and analytics events into small, concise types yields clean call-sites and helps organize the code backing up the data reported for each event.

## Requirements

- Xcode 14.0+
- Swift 5.5+

## Installation

The easiest way to install Telemetry is by adding a dependency via SPM.

```swift
        .package(
            name: "Telemetry",
            url: "https://github.com/krogerco/telemetry-ios.git",
            .upToNextMajor(from: Version(1, 0, 0))
        )
```

## Quick Start

Getting basic telemetry working is quick and easy:

1. Create a telemeter for the application to use.

    ```swift
    var telemeter = StandardTelemeter()
    ```

1. Add your relays to the telemeter.

    ```swift
    telemeter.add(relay: ConsoleRelay())
    telemeter.add(relay: ExternalServiceRelay())
    ```

1. Define events

    ```swift
    enum CartEvent: Metron {
        case addedToCart
        case removedFromCart

        var message: String {
            switch self {
            case .addedToCart:   return "Added product to cart."
            case .removedFromCart: return "Removed product from cart."
            }
        }
    ```

1. Record events

    ```swift
    telemeter.record(CartEvent.addedToCart)
    ```

Events are routed to each relay and processed if applicable.

## Documentation

Gauntlet has full DocC documentation. After adding to your project, `Build Documentation` to add to your documentation viewer.

### Online Documentation

[Getting Started](Sources/Telemetry/Documentation.docc/GettingStarted.md)
[Full Documentation](https://krogerco.github.io/Telemetry-iOS/documentation/telemetry)


## Communication

If you have issues or suggestions, please open an issue on GitHub.
