/// An operation a service exposes over HTTP.
///
/// ```json
/// { "name": "getPet", "method": "get", "path": "/pets/{id}", "response": "Pet" }
/// { "name": "createPet", "method": "post", "path": "/pets", "request": "Pet", "response": "Pet" }
/// ```
///
/// Segments of `path` wrapped in braces are parameters. ``pathParameters`` lists their names in order.
public struct Endpoint: Codable, Sendable, Equatable {

    // MARK: - Initializers

    /// Create an endpoint.
    /// - Parameters:
    ///   - name: The name of the endpoint.
    ///   - method: The HTTP method the endpoint responds to.
    ///   - path: The path of the endpoint, relative to the service's base URL.
    ///   - request: The name of the type sent as the request body, if any.
    ///   - response: The name of the type returned in the response body, if any.
    public init(
        name: String,
        method: HTTPMethod,
        path: String,
        request: String? = nil,
        response: String? = nil
    ) {
        self.name = name
        self.method = method
        self.path = path
        self.request = request
        self.response = response
    }

    // MARK: - API

    /// The name of the endpoint.
    public var name: String

    /// The HTTP method the endpoint responds to.
    public var method: HTTPMethod

    /// The path of the endpoint, relative to the service's base URL.
    ///
    /// Segments wrapped in braces, such as `{id}` in `/pets/{id}`, are parameters.
    public var path: String

    /// The name of the type sent as the request body, if any.
    public var request: String?

    /// The name of the type returned in the response body, if any.
    public var response: String?

    /// The names of the parameters in ``path``, in order.
    ///
    /// For the path `/users/{userID}/posts/{postID}`, this is `["userID", "postID"]`.
    public var pathParameters: [String] {
        path
            .split(separator: "/")
            .compactMap { segment in
                guard segment.hasPrefix("{"), segment.hasSuffix("}") else {
                    return nil
                }
                return String(segment.dropFirst().dropLast())
            }
    }

}
