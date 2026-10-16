/// A field of a structure.
///
/// ```json
/// { "name": "status", "type": "Status", "optional": true }
/// ```
///
/// The `optional` key may be omitted, in which case the field is required.
public struct Field: Codable, Sendable, Equatable {

    // MARK: - Initializers

    /// Create a field.
    /// - Parameters:
    ///   - name: The name of the field.
    ///   - type: The type of the field's value.
    ///   - isOptional: Whether the field may be absent. Defaults to `false`.
    public init(
        name: String,
        type: FieldType,
        isOptional: Bool = false
    ) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
    }

    // MARK: - API

    /// The name of the field.
    public var name: String

    /// The type of the field's value.
    public var type: FieldType

    /// Whether the field may be absent.
    public var isOptional: Bool

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(FieldType.self, forKey: .type)
        isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? false
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        if isOptional {
            try container.encode(isOptional, forKey: .isOptional)
        }
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case isOptional = "optional"
    }

}
