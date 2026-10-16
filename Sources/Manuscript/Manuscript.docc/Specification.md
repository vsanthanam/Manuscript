# Specification

The structure of a Manuscript document.

## Overview

A Manuscript document is a JSON object. Keys not listed here are ignored, so documents may carry extra information for other tools. Names are not validated beyond being non-empty strings, so a tool that turns them into identifiers is responsible for making them valid in its target language.

### Service

The root object. Parsed as ``Service``.

| Key | Type | Required | Meaning |
| --- | --- | --- | --- |
| `name` | string | yes | The name of the service. |
| `types` | array of type | yes | The types the service exchanges. |
| `endpoints` | array of endpoint | yes | The endpoints the service exposes. |

### Type

A named type. Parsed as ``TypeDefinition``. Exactly one of `fields` and `cases` must be present. A type with `fields` is a structure; a type with `cases` is an enumeration.

| Key | Type | Required | Meaning |
| --- | --- | --- | --- |
| `name` | string | yes | The name of the type. |
| `documentation` | string | no | A description of the type. |
| `fields` | array of field | one of | The fields of a structure. May be empty. |
| `cases` | array of string | one of | The cases of an enumeration. |

### Field

A field of a structure. Parsed as ``Field``.

| Key | Type | Required | Meaning |
| --- | --- | --- | --- |
| `name` | string | yes | The name of the field. |
| `type` | field type | yes | The type of the field's value. |
| `optional` | boolean | no | Whether the field may be absent. Defaults to `false`. |

### Field type

The type of a field's value. Parsed as ``FieldType``. One of:

- The string `"string"`, `"integer"`, `"double"`, or `"boolean"` for a primitive.
- Any other non-empty string, naming a type declared in the same service.
- An object with a single `array` key whose value is itself a field type, for an array. Arrays may nest.

```json
"integer"
"Pet"
{ "array": "Pet" }
{ "array": { "array": "double" } }
```

The parser does not check that a referenced type exists. Tools that need that guarantee should check ``Service/type(named:)`` for each ``FieldType/reference(_:)`` they encounter.

### Endpoint

An operation the service exposes over HTTP. Parsed as ``Endpoint``.

| Key | Type | Required | Meaning |
| --- | --- | --- | --- |
| `name` | string | yes | The name of the endpoint. |
| `method` | string | yes | One of `get`, `post`, `put`, `patch`, or `delete`. |
| `path` | string | yes | The path, relative to the service's base URL. |
| `request` | string | no | The name of the type sent as the request body. |
| `response` | string | no | The name of the type returned in the response body. |

A path segment wrapped in braces, such as `{id}` in `/pets/{id}`, is a parameter. ``Endpoint/pathParameters`` lists the parameter names in order. Only whole segments are parameters; `/pets/{id}.json` is not.
