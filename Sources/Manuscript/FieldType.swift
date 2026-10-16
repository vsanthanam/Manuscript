/// The type of a field's value.
///
/// Primitive types and references are spelled as strings in JSON. The four primitive names are reserved; any other
/// string refers to a ``TypeDefinition`` declared by the same service. Arrays are objects with a single `array` key
/// holding the element type, and may nest.
///
/// ```json
/// "string"
/// "Pet"
/// { "array": "string" }
/// { "array": { "array": "Pet" } }
/// ```
public indirect enum FieldType: Codable, Sendable, Equatable {

    /// A string.
    case string

    /// An integer.
    case integer

    /// A floating-point number.
    case double

    /// A boolean.
    case boolean

    /// An array of the given element type.
    case array(FieldType)

    /// A type declared by the service, by name.
    case reference(String)

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self = try .array(container.decode(FieldType.self, forKey: .array))
        } else {
            let container = try decoder.singleValueContainer()
            let name = try container.decode(String.self)
            switch name {
            case Self.stringName:
                self = .string
            case Self.integerName:
                self = .integer
            case Self.doubleName:
                self = .double
            case Self.booleanName:
                self = .boolean
            case "":
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "A type reference cannot be empty."
                )
            default:
                self = .reference(name)
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .array(element):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(element, forKey: .array)
        case .string:
            var container = encoder.singleValueContainer()
            try container.encode(Self.stringName)
        case .integer:
            var container = encoder.singleValueContainer()
            try container.encode(Self.integerName)
        case .double:
            var container = encoder.singleValueContainer()
            try container.encode(Self.doubleName)
        case .boolean:
            var container = encoder.singleValueContainer()
            try container.encode(Self.booleanName)
        case let .reference(name):
            var container = encoder.singleValueContainer()
            try container.encode(name)
        }
    }

    // MARK: - Private

    private static let stringName = "string"
    private static let integerName = "integer"
    private static let doubleName = "double"
    private static let booleanName = "boolean"

    private enum CodingKeys: String, CodingKey {
        case array
    }

}
