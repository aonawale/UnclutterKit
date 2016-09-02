import Foundation

public protocol PathComponentProtocol {
	var path: String { get }
}

public struct PathComponent: PathComponentProtocol {

	public let path: String

	init(fromString string: String) {
		path = string.trimmingCharacters(in: CharacterSet(charactersIn: slash))
	}
}

extension PathComponent: ExpressibleByExtendedGraphemeClusterLiteral {

	public init(extendedGraphemeClusterLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: ExpressibleByUnicodeScalarLiteral {

	public init(unicodeScalarLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: ExpressibleByStringLiteral {

	public init(stringLiteral value: String) {
		self.init(fromString: value)
	}
}

extension Sequence where Self.Iterator.Element: PathComponentProtocol {

	public var joined: String {
		return reduce("") { $0 + slash + $1.path }
	}
}

private let slash = "/"
