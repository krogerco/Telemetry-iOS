# Relays

Relays are the final destinations of events. Relays take the event and it's metadata and do something useful with it (e.g. display in the console, pass to an 3rd party SDK, etc).

## Standard Relays

Telemetry ships with two standard Relays, and you can create your own custom Relays to communicate with 3rd party SDKs, etc.

- **ConsoleRelay**: Prints incoming metron messages to the Xcode console for debugging and monitoring. You can pass in an array of Significance facets that are required before a metron will be printed.
- **PublisherRelay**: Exposes a Combine publisher that code can subscribe to to receive specific types. Can be useful for detecting events being sent and displaying UI element or triggering other functionality.

## Recommended Coding Patterns

On iOS, we recommend the following patterns:

* Don't define large monolithic collections of events. A file with hundreds of events becomes difficult to maintain and understand.
* Create small batches of events related to a particular domain. For example, if you have a logic controller that should have a set of events, create a file like `MyLogicControllerEvents.swift` that contains only the events related to that logic controller.

## Relay Configuration

### Filters

Each relay type will have its own configuration API. For example, the `ConsoleRelay` is initialized with an array of Significances that should be accepted and printed to the console.

### Metron and Facet Conversion

By default, relays are passed the `Metroid` wrapping each event and are responsible for converting it to the data format they require.

Depending on the functionality the Relay needs, it can look for specific Metron or Facet types.

For Metrons, the relay can check for specific types or conformance to interested protocols by optional casting the Metron.

```swift
    func process(metroid: Metroid<MetronType>) {
        if let myMetron = metroid.value as? SomeProtocol {
            // Process the metron...
        }
    }
```

Relays can also look for Facets of a specific type or type conformance.

```swift
    func process(metroid: Metroid<MetronType>) {
        let facets = metroid.facets

        if let myFacet = facets.first(ofType: SomeType.self) {
            // Process the metron...
        }
    }
```

Telemetry exposes a number of Array extensions specifically tailored to finding and filtering Facets of specific types.
