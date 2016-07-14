protocol SectionProtocol {
	associatedtype Element

	var items: [Element] { get set }
	var title: String? { get set }
}

class Section<Element>: SectionProtocol {
	var items: [Element]
	var title: String?

	init(items: [Element]) {
		self.items = items
	}
}
