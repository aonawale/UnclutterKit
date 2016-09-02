import Foundation

public protocol DataSourceProtocol: class {

	associatedtype Item

	func item(at: IndexPath) -> Item
	func numberOfItems(inSection: Int) -> Int
	func numberOfSections() -> Int
	func titleForHeader(inSection section: Int) -> String?
}
