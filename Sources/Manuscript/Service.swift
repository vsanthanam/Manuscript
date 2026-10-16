// Manuscript
// Service.swift
//
// MIT License
//
// Copyright (c) 2026 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// A service described in Manuscript: the types it exchanges and the endpoints it exposes.
///
/// A service is the root of a Manuscript document. Decode one from JSON with ``init(contentsOf:)`` or ``init(data:)``,
/// or build one in code with ``init(name:types:endpoints:)``.
///
/// ```json
/// {
///   "name": "Petstore",
///   "types": [ ... ],
///   "endpoints": [ ... ]
/// }
/// ```
public struct Service: Codable, Sendable, Equatable {

    // MARK: - Initializers

    /// Create a service.
    /// - Parameters:
    ///   - name: The name of the service.
    ///   - types: The types the service exchanges.
    ///   - endpoints: The endpoints the service exposes.
    public init(
        name: String,
        types: [TypeDefinition] = [],
        endpoints: [Endpoint] = []
    ) {
        self.name = name
        self.types = types
        self.endpoints = endpoints
    }

    /// Decode a service from Manuscript JSON.
    /// - Parameter data: The JSON document.
    /// - Throws: A `DecodingError` if the document is not valid Manuscript.
    public init(data: Data) throws {
        self = try JSONDecoder().decode(Service.self, from: data)
    }

    /// Decode a service from a Manuscript JSON file.
    /// - Parameter url: The location of the file.
    /// - Throws: An error if the file cannot be read, or a `DecodingError` if it is not valid Manuscript.
    public init(contentsOf url: URL) throws {
        try self.init(data: Data(contentsOf: url))
    }

    // MARK: - API

    /// The name of the service.
    public var name: String

    /// The types the service exchanges, in declaration order.
    public var types: [TypeDefinition]

    /// The endpoints the service exposes, in declaration order.
    public var endpoints: [Endpoint]

    /// Look up a type by name.
    /// - Parameter name: The name of the type.
    /// - Returns: The first type with that name, or `nil` if the service declares no such type.
    public func type(named name: String) -> TypeDefinition? {
        types.first { $0.name == name }
    }

    /// Look up an endpoint by name.
    /// - Parameter name: The name of the endpoint.
    /// - Returns: The first endpoint with that name, or `nil` if the service declares no such endpoint.
    public func endpoint(named name: String) -> Endpoint? {
        endpoints.first { $0.name == name }
    }

}
