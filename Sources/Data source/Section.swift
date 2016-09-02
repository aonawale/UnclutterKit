public protocol SectionProtocol {
	associatedtype Element

	var items: [Element] { get set }
	var title: String? { get set }
}

public class Section<Element>: SectionProtocol {
	public var items: [Element]
	public var title: String?

	public init(items: [Element]) {
		self.items = items
	}
}
