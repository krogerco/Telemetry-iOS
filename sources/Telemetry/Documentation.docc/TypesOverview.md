# Types Overview

A summary of the high level concepts and types in Telemetry.

## Metron

A ``Metron`` is a protocol representing a type that can be measured in Telemetry and is what you pass to a Telemeter. A Metron could be anything from an analytics event, an error, a log message, or anything else you want to measure in your app or framework. Metrons are considered to be immutable.

## Telemeter

A ``Telemeter`` is a type used to record Metrons. It has one required function `record(_ metron: Metron)` which takes a Metron and ensures that it finds its way to the appropriate destinations. Two concrete Telemeters are provided in Telemeters:

* ``StandardTelemeter`` is a Telemeter implementation that implements Relay support. The ``StandardTelemeter`` is the ideal starting point when working with Telemetry.
* ``MockTelemeter`` is a mock implementation of Telemeter that can be used for unit testing to validate you record the expected events.

## Metroid

``Metroid`` is a type that wraps a ``Metron`` and it what is passed to a `Relay` to be processed. It contains the date that the Metron was recorded as well as all of the Facets attached along the way. It also has convenience accessors for common properties like `message` and `significance`.

## Facet

``Facet`` is a protocol representing any metadata to be associated with a ``Metron``. Metrons can have a built in set of initial facets (typically 1-2) which are copied into the Metroid when the Metron is recorded. Later processing stages may add more facets, or replace existing Facets, before the event makes it's way to the relays.

## Relay

A ``Relay`` is a type that relays a ``Metroid``/``Metron`` to an appropriate destination. An example of a ``Relay`` is ``ConsoleRelay`` which prints a ``Metron`` to the Xcode console. Additional relays can be built to send a ``Metron`` to other relevant locations, such as 3rd party SDKs for external reporting.
