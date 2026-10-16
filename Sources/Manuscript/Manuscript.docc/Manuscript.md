# ``Manuscript``

A small JSON format for describing a service, and a Swift parser for it.

## Overview

A Manuscript document describes a service in two parts: the types it exchanges and the endpoints it exposes. The format is deliberately tiny so that tools built on it, such as code generators, can focus on what they emit rather than on parsing.

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

Decode a document into a ``Service`` and walk its ``Service/types`` and ``Service/endpoints``:

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

Every type is `Codable`, so a service built in code can be written back out as a valid document.

## Topics

### Format

- <doc:Specification>

### Services

- ``Service``

### Types

- ``TypeDefinition``
- ``Field``
- ``FieldType``

### Endpoints

- ``Endpoint``
- ``HTTPMethod``
