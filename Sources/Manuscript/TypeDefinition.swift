/// A named type exchanged by a service.
///
/// A type is either a structure with fields or an enumeration with cases. In JSON, the two are told apart by which
/// key is present: `fields` or `cases`. Exactly one must appear.
///
/// ```json
/// { "name": "Status", "cases": ["available", "sold"] }
/// { "name": "Pet", "documentation": "A pet in the store.", "fields": [ ... ] }
/// ```
public struct TypeDefinition: Codable, Sendable, Equatable {

    // MARK: - Initializers

    /// Create a type definition.
    /// - Parameters:
    ///   - name: The name of the type.
    ///   - documentation: A description of the type, if any.
    ///   - shape: Whether the type is a structure or an enumeration, and its members.
    public init(
        name: String,
        documentation: String? = nil,
        shape: Shape
    ) {
        self.name = name
        self.documentation = documentation
        self.shape = shape
    }

    // MARK: - API

    /// The members of a type.
    public enum Shape: Sendable, Equatable {

        /// A structure with the given fields.
        case structure([Field])

        /// An enumeration with the given cases.
        case enumeration([String])

    }

    /// The name of the type.
    public var name: String

    /// A description of the type, if any.
    public var documentation: String?

    /// Whether the type is a structure or an enumeration, and its members.
    public var shape: Shape

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        documentation = try container.decodeIfPresent(String.self, forKey: .documentation)
        let fields = try container.decodeIfPresent([Field].self, forKey: .fields)
        let cases = try container.decodeIfPresent([String].self, forKey: .cases)
        switch (fields, cases) {
        case let (fields?, nil):
            shape = .structure(fields)
        case let (nil, cases?):
            shape = .enumeration(cases)
        case (nil, nil):
            throw DecodingError.dataCorruptedError(
                forKey: .fields,
                in: container,
                debugDescription: "A type must declare either \"fields\" or \"cases\"."
            )
        case (.some, .some):
            throw DecodingError.dataCorruptedError(
                forKey: .cases,
                in: container,
                debugDescription: "A type cannot declare both \"fields\" and \"cases\"."
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(documentation, forKey: .documentation)
        switch shape {
        case let .structure(fields):
            try container.encode(fields, forKey: .fields)
        case let .enumeration(cases):
            try container.encode(cases, forKey: .cases)
        }
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case name
        case documentation
        case fields
        case cases
    }

}
