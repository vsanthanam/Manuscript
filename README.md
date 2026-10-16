# Manuscript

[![MIT License](https://img.shields.io/github/license/vsanthanam/Manuscript)](https://github.com/vsanthanam/Manuscript/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/vsanthanam/Manuscript?include_prereleases)](https://github.com/vsanthanam/Manuscript/releases)
[![Build Status](https://img.shields.io/github/check-runs/vsanthanam/Manuscript/main)](https://github.com/vsanthanam/Manuscript/actions)
[![Swift Version](https://img.shields.io/badge/swift-6.2%20%7C%206.3%20%7C%206.4-critical)](https://swift.org)

A small JSON format for describing a service

## Overview

A Manuscript document describes a service in two parts: the types it exchanges and the endpoints it exposes. The format is deliberately tiny so that tools built on it, such as code generators, can focus on what they emit rather than on parsing. It exists to support the [Calligraphy](https://github.com/vsanthanam/Calligraphy) tutorials, which build a code generator on top of it, but nothing about it is specific to Calligraphy.

```json
{
  "name": "Petstore",
  "types": [
    { "name": "Status", "cases": ["available", "sold"] },
    { "name": "Pet", "documentation": "A pet in the store.", "fields": [
      { "name": "id", "type": "integer" },
      { "name": "name", "type": "string" },
      { "name": "status", "type": "Status", "optional": true },
      { "name": "tags", "type": { "array": "string" } }
    ]}
  ],
  "endpoints": [
    { "name": "listPets", "method": "get", "path": "/pets", "response": "Pet" },
    { "name": "getPet", "method": "get", "path": "/pets/{id}", "response": "Pet" },
    { "name": "createPet", "method": "post", "path": "/pets", "request": "Pet", "response": "Pet" }
  ]
}
```

A type is a structure when it has `fields` and an enumeration when it has `cases`. A field's type is one of the primitives `string`, `integer`, `double`, or `boolean`, the name of another type in the same service, or `{ "array": <type> }`. Segments of an endpoint's path wrapped in braces are parameters. The full format is described in the [specification](Sources/Manuscript/Manuscript.docc/Specification.md).

## Usage

Decode a document into a `Service` and walk its types and endpoints:

```swift
import Manuscript

let service = try Service(contentsOf: URL(filePath: "petstore.json"))

for type in service.types {
    switch type.shape {
    case let .structure(fields):
        print("struct \(type.name) with \(fields.count) fields")
    case let .enumeration(cases):
        print("enum \(type.name) with \(cases.count) cases")
    }
}

for endpoint in service.endpoints {
    print("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) takes \(endpoint.pathParameters)")
}
```

Every type is `Codable`, `Sendable`, and `Equatable`, so a service built in code can be written back out as a valid document.

## Installation

Add Manuscript to your package as a dependency:

```swift
dependencies: [
    .package(url: "https://github.com/vsanthanam/Manuscript", from: "1.0.0")
]
```

Then add the `Manuscript` product to any target that needs it:

```swift
.product(name: "Manuscript", package: "Manuscript")
```

Manuscript supports Swift 6.2 and later on every platform Foundation runs on.

## Documentation

Reference documentation is available on the [Swift Package Index](https://swiftpackageindex.com/vsanthanam/Manuscript/documentation/manuscript), or build it locally with `mise preview-docs`.

## License

Manuscript is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
