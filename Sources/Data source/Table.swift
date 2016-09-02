import UIKit

public struct TableItem {

	public init<Cell: UITableViewCell, ViewModel>
		(_: Cell.Type,
		 viewModel: ViewModel,
		 onDelete: ((ViewModel, IndexPath) -> Void)? = nil,
		 onDidSelect: ((ViewModel, IndexPath) -> Void)? = nil) where
		Cell: ReusableViewProtocol, Cell.ViewModel == ViewModel {

		dequeueCell = { (tableView, indexPath) in
			var cell = tableView.dequeueReusableCell(for: indexPath) as Cell
			cell.viewModel = viewModel
			return cell
		}
		deleteItem = {
			onDelete?(viewModel, $0)
		}
		isDeletable = onDelete != nil
		didSelectItem = {
			onDidSelect?(viewModel, $0)
		}
	}

	fileprivate let dequeueCell: (UITableView, IndexPath) -> UITableViewCell
	fileprivate let deleteItem: (IndexPath) -> Void
	fileprivate let didSelectItem: (IndexPath) -> Void
	fileprivate let isDeletable: Bool
}

public struct Table {

	public init<T: DataSourceProtocol>(dataSource: T) where T.Item == TableItem {
		helper = TableViewHelper(AnyDataSource(dataSource))
	}

	private let helper: TableViewHelper

	public func configure(with tableView: UITableView) {
		tableView.dataSource = helper
		tableView.delegate = helper
	}
}

private final class TableViewHelper: NSObject {

	let dataSource: AnyDataSource<TableItem>

	init(_ dataSource: AnyDataSource<TableItem>) {
		self.dataSource = dataSource
	}
}

extension TableViewHelper: UITableViewDataSource {

	func numberOfSections(in _: UITableView) -> Int {
		return dataSource.numberOfSections()
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.numberOfItems(inSection: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return dataSource.item(at: indexPath).dequeueCell(tableView, indexPath)
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dataSource.titleForHeader(inSection: section)
	}

	func tableView(_ tableView: UITableView,
	               commit editingStyle: UITableViewCellEditingStyle,
	               forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			dataSource.item(at: indexPath).deleteItem(indexPath)
		default: ()
		}
	}

	@objc(tableView:editingStyleForRowAtIndexPath:)
	func tableView(_ tableView: UITableView,
	               editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return dataSource.item(at: indexPath).isDeletable ? .delete : .none
	}
}

extension TableViewHelper: UITableViewDelegate {

	func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		dataSource.item(at: indexPath).didSelectItem(indexPath)
	}
}
