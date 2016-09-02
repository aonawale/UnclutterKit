import Foundation

class AnyDataSource<Item>: DataSourceProtocol {

	init<D: DataSourceProtocol>(_ dataSource: D) where D.Item == Item {
		_item = dataSource.item
		_numberOfItems = dataSource.numberOfItems
		_numberOfSections = dataSource.numberOfSections
		_titleForHeader = dataSource.titleForHeader
	}

	private let _item: (IndexPath) -> Item
	func item(at indexPath: IndexPath) -> Item {
		return _item(indexPath)
	}

	private let _numberOfItems: (Int) -> Int
	func numberOfItems(inSection section: Int) -> Int {
		return _numberOfItems(section)
	}

	private let _numberOfSections: () -> Int
	func numberOfSections() -> Int {
		return _numberOfSections()
	}

	private let _titleForHeader: (Int) -> String?
	func titleForHeader(inSection section: Int) -> String? {
		return _titleForHeader(section)
	}
}
