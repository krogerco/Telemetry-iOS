# Telemeters

`Telemeter` itself is a protocol. Telemetry supplies a standard implementation of this in the  `StandardTelemeter` class. StandardTelemeter has a rich feature set and is the recommended Telemeter for most use cases.

## The Main Telemeter

Telemetry defines a StandardTelemeter at `StandardTelemeter.shared` that is intended to be the root telemeter for an application. The application should save a reference to this telemeter as the "application telemeter" in a place that makes sense for your application architecture.

This telemeter should be the one that the application configures to suit its needs, and it should be the telemeter injected into features and modules.

Other code SHOULD NOT directly reference `StandardTelemeter.shared`. Telemeters should always be injected from higher level code to lower level code, as a part of clean engineering practices.

## Configuration

Relays can be added to a `StandardTelemeter` by calling `.add(relay: ...)`

Example:

```swift
    telemeter.add(relay: ConsoleRelay())
    telemeter.add(relay: OtherRelay())
```

## Adding Facets

You can create a new telemeter that will add a specified array of Facets to all Metrons recorded. This Telemeter will forward all recorded Metrons to its parent Telemeter. This can be used to create a module-specific telemeter that will add a facet describing the module the Metrons were recorded in while preserving the configuration of the telemeter you were provided with.

```swift
private(set) var cartTelemeter: Telemeter

public func setCartTelemeter(_ telemeter: Telemeter) {
    let facets = [Prefix("Cart")]
    cartTelemeter = telemeter.telemeter(with: facets)
}
```

