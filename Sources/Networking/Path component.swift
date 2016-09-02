import Foundation

protocol PathComponentProtocol {
	var path: String { get }
}

struct PathComponent: PathComponentProtocol {

	let path: String

	init(fromString string: String) {
		path = string.trimmingCharacters(in: CharacterSet(charactersIn: slash))
	}
}

extension PathComponent: ExpressibleByExtendedGraphemeClusterLiteral {

	init(extendedGraphemeClusterLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: ExpressibleByUnicodeScalarLiteral {

	init(unicodeScalarLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: ExpressibleByStringLiteral {

	init(stringLiteral value: String) {
		self.init(fromString: value)
	}
}

extension Sequence where Self.Iterator.Element: PathComponentProtocol {

	var joined: String {
		return reduce("") { $0 + slash + $1.path }
	}
}

private let slash = "/"
