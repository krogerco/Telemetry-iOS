# Supporting Analytics

While the built in message support and the default facets supplied by Telemetry may be enough for basic logging, you will probably want to extend your metrons with custom information needed by the installed relays.

For example, let say you need to track an event for the user adding an item to a cart.

```swift
enum CartEvents: Metron {
    case addToCart(String)
    case removeFromCart(String)
    
    var message: String {
        switch self {
        case .addToCart(let sku): return "Added \(sku) to cart."
        case .removeFromCart(let sku): return "Removed \(sku) from cart."
        }
    }
    
    var facets: [Facet] {
        switch self {
        case .addToCart: return [.informational]
        case .removeFromCart: return [.informational]
        }
    }
}
```

The above may be fine for debug logging, but to call your analytics service maybe you need to create and populate a specific type with more information from the call site.

There are two ways to accomplish this: extending the event type with conformance to a custom protocol, or adding a custom facet.

### Protocol Conformance

With this method you extend your even type to conform to a protocol that, in this example, can vend a common analytic type or other base type your analytics system needs.

```swift
extension CartEvents: SomeAnalyticsProtocol {
    var analyticsInfo: SomeAnalyticsBaseType {
        switch self {
        case .addToCart(let sku): return AddToCartAnalytic(sku)
        case .removeFromCart(let sku): return RemoveFromCartAnalytic(sku)
        }
    }
}
```

Your analytics relay would then look something like this:

```swift
func process(metroid: Metroid<SomeAnalyticsProtocol>) {
    // Because of generics, the metroid `value` is the correct type.
    // If the metron was non-conforming, telemetry would skip calling this relay.
    let analytic = metroid.value.analyticsInfo
    
    // Record the analytic.
    analyticsSDK.record(analytic)
}
```

The advantage to this method is that while the needed data is captured when the event is recorded, the expense of converting to the ananlytics type is delayed until the relay requests it.

### Custom Facets

Another way to provide needed data is via custom facets:

```swift
struct AddToCartAnalytic: SomeAnalyticsBaseType, Facet {
    let sku: String
    ...
}
```

```swift
enum CartEvents: Metron {
    case addToCart(String)
    case removeFromCart(String)
    
    var facets: [Facet] {
        switch self {
        case .addToCart(let sku): return [.informational, AddToCartAnalytic(sku)]
        case .removeFromCart: return [.informational, RemoveFromCartAnalytic(sku)]
        }
    }
}
```

In this case, your relay might accept all metrons but filter by facet type:

```swift
func process(metroid: Metroid<Metron>) {
    // Find all analytics facets in this metron.
    let analyticFacets = metroid.facets.filter(by: SomeAnalyticsBaseType.self)
    
    guard !analyticFacets.isEmpty else { return }
    
    // Send them.
    analyticsSDK.record(analyticFacets)
}
```
