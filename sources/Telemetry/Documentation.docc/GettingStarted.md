# Getting Started With Telemetry

A quick guide to using Telemetry.

## Quick Start Guide

#### First, Create a Telemeter

A ``Telemeter`` is used to record events anywhere in your code. Creating one is simple:

```swift
let telemeter = StandardTelemeter()
```

#### Next, Configure Relays

A telemeter will need to send data somewhere to be useful, this is where ``Relay``s come in. The ``ConsoleRelay`` will 
output events with the specified ``Significance`` to the console. Let's add one that will output all metrons.

```swift
telemeter.add(relay: ConsoleRelay(allowedSignificances: .all)
```

#### Define an Event

You'll define events that you record to a telemeter. An event you define must conform to the ``Metron`` protocol.

```swift
enum AddToCartEvent: Metron {
    case itemAdded(Product)
    case addFailed(Error)

    var message: String {
        switch self {
        case .itemAdded(let product):
            return "Added item to cart: \(product.name)"

        case .addFailed:
            return "Failed to add item to cart"
        }
    }

    var facets: [Facet] {
        switch self {
        case .itemAdded: return [.informational]
        case .addFailed(let error): return [Failure(error), .error]
        }
    }
}
```

#### Finally, Record the event

Recording an event is easy, just call `.record` on a `Telemeter` instance:

```swift
telemeter.record(AddToCartEvent.itemAdded(product))
```
