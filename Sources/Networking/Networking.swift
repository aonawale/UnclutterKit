import Foundation

public enum HTTPMethod {
    case get, put, post, path, head
}

extension HTTPMethod {
    public var string: String {
        return "\(self)".uppercased()
    }
}

public enum URLScheme: String {
	case http
	case https
}

public protocol PathComponentsProtocol {
    var pathComponents: [String] { get }
}

extension URLComponents {
    public init(host: String, scheme: URLScheme = .https, endpoint: PathComponentsProtocol) {
        self.init()
        self.host = host
        self.scheme = scheme.rawValue
        let separator = "/"
        self.path = separator + endpoint.pathComponents.joined(separator: separator)
    }
}

extension URLRequest {
    public init?(url: URL, method: HTTPMethod, body: [String: Any]? = nil) {
        self.init(url: url)
        httpMethod = method.string
        if let body = body {
            httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
    }
}
