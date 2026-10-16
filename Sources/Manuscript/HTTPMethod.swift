/// An HTTP method an endpoint responds to.
///
/// Spelled in lowercase in JSON: `"get"`, `"post"`, `"put"`, `"patch"`, or `"delete"`.
public enum HTTPMethod: String, Codable, Sendable, CaseIterable {

    /// The `GET` method.
    case get

    /// The `POST` method.
    case post

    /// The `PUT` method.
    case put

    /// The `PATCH` method.
    case patch

    /// The `DELETE` method.
    case delete

}
