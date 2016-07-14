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

extension PathComponent: ExtendedGraphemeClusterLiteralConvertible {

	init(extendedGraphemeClusterLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: UnicodeScalarLiteralConvertible {

	init(unicodeScalarLiteral value: String) {
		self.init(fromString: value)
	}
}

extension PathComponent: StringLiteralConvertible {

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
