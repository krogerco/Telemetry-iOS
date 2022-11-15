# Defining Events

Crafting the events you want to record is an important part of adding consistent logging and analytics to your application or framework. Events will typically represent important user interactions or internal actions that have taken place.

While events can be of any base type (`enum`, `struct`, `class`) that can conform to ``Metron``, in most cases `enum`s yield the most concise call sites and implementations.

First, define all of the events you want to record in a feature or other section of code.

```swift
extension DefaultLocationPermissionManager {
    enum Events {
        case skippingPermissionRequest
        case permissionGranted
        case permissionDenied(Error)
    }
}
```

> Tip: Don't define large monolithic collections of events. A file with hundreds of events becomes difficult to maintain and understand. Insetad, create small batches of events related to a particular domain.

Extend the type for basic `Metron` conformance.

```swift
extension DefaultLocationPermissionManager.Events: Metron {
    var message: String {
        switch self {
        case .permissionsManagerStarting: return "Location permission manager starting"
        case .skippingPermissionRequest:  return "Location permission manager skipping permission request"
        case .permissionGranted:          return "Location permission manager granted permission"
        case .permissionDenied(let error): return "Location permission manager denied permission \(error)"
        }
    }
}
```

## Define Messages

Every event should have a human readable `message`. This name will be used by Relays that report human readable data (e.g. console, etc). In the event no message is provided, a less readable message will be automatically synthesized from the type.

> Tip: The target audience for a Metron's message is developers. The message should concisely describe the event that occurred, providing sufficient detail to understand what occurred. At a minimum, this message will be used in the console output with the ``ConsoleRelay``.

## Define Facets

Additionally, every event should supply a default set of Facets. Facets are like metadata that describe the intent of the event to downstream clients without them needing to know the exact type of the event.

```swift
    var facets: [Facet] {
        switch self {
        case .permissionsManagerStarting:   return [.verbose]
        case .skippingPermissionRequest:    return [.informational]
        case .permissionGranted:            return [.informational]
        case .permissionDenied(let error):  return [.error, Failure(error)]
        }
    }
```

In the above example, we've declared that `permissionsManagerStarting` is a ``Significance/verbose`` event, meaning it's probably not something that should always be processed by relays (e.g. displayed in the console).

The next two events are marked as `informational`, meaning you think this is generally useful information and would be appropriate for most relays.

The final event represents and error occurring in the code. It is marked as `error`, and the exact error is attached with a `Failure` facet.

All metrons are encouraged to provide a ``Significance`` facet to accurately describe how important that event is. The significance is used by the ``ConsoleRelay`` to determine which events will be printed to the console. The relay can be configured to output only events meeting a specific significance level. If no significance is specified it will default to `verbose`, unless there is a `Failure` facet present which will default to `error`.

Another common facet type is the ``Failure`` facet. This signifies that an error has occurred, and requires an `Error` instance that describes the underlying issue. Errors included in a failure will be printed to the console by the ``ConsoleRelay`` along with the Metron's message. When defining a custom `Error` add conformance to `CustomStringConvertible` to customize the output of the error with the ``ConsoleRelay``.

## Recording Events

With the above patterns, the call sites in application and framework code is reduced to a single line of code:

```swift
telemeter.record(Events.permissionsManagerStarting)
```

### Other Ways to Record

While defining your own `Metron`s is recommended there are times when you just need to quickly log something while developing a feature. `Telemeter` provides a few functions to help out here.

``Telemeter/debugLog(_:error:file:line:)`` allows logging a specific message and an optional error. It will also capture the file and line number where the message was recorded:

```swift
telemeter.debugLog("The button was tapped!")
```

``Telemeter/internalError(_:error:file:line:)`` can be used in situations where you hit some internal failure state and cannot proceed normally. These should represent serious errors that you would not expect to run into in normal usage. These are great to use in `guard` statements that are not expected to ever fail, but you want to know when they happen.

```swift
guard let thing = thingThatShouldNotBeNil else {
    telemeter.internalError("The thing that should never be nil was nil! This shouldn't happen!")
    return
}
```
