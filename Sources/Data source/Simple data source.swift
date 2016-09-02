import Foundation

class SimpleDataSource<Model, Item, S: SectionProtocol> where S.Element == Model {

	init(sections: [S], transform: @escaping (Model) -> Item) {
		self.sections = sections
		self.transform = transform
	}

	fileprivate var sections: [S]
	fileprivate let transform: (Model) -> Item
}

extension SimpleDataSource: DataSourceProtocol {

	func item(at indexPath: IndexPath) -> Item {
		return transform(sections[indexPath.section].items[indexPath.row])
	}

	func numberOfItems(inSection section: Int) -> Int {
		return sections[section].items.count
	}

	func numberOfSections() -> Int {
		return sections.count
	}

	func titleForHeader(inSection section: Int) -> String? {
		return sections[section].title
	}
}
