import UIKit

struct TableItem {

	init<Cell: UITableViewCell, ViewModel where
		Cell: ReusableViewProtocol, Cell.ViewModel == ViewModel>
		(_: Cell.Type,
		 viewModel: ViewModel,
		 onDelete: ((viewModel: ViewModel, indexPath: IndexPath) -> Void)? = nil,
		 onDidSelect: ((viewModel: ViewModel, indexPath: IndexPath) -> Void)? = nil) {

		dequeueCell = { (tableView, indexPath) in
			var cell = tableView.dequeueReusableCell(for: indexPath) as Cell
			cell.viewModel = viewModel
			return cell
		}
		deleteItem = {
			onDelete?(viewModel: viewModel, indexPath: $0)
		}
		isDeletable = onDelete != nil
		didSelectItem = {
			onDidSelect?(viewModel: viewModel, indexPath: $0)
		}
	}

	private let dequeueCell: (from: UITableView, for: IndexPath) -> UITableViewCell
	private let deleteItem: (at: IndexPath) -> Void
	private let didSelectItem: (at: IndexPath) -> Void
	private let isDeletable: Bool
}

struct Table {

	init<T: DataSourceProtocol where T.Item == TableItem>(dataSource: T) {
		helper = TableViewHelper(AnyDataSource(dataSource))
	}

	private let helper: TableViewHelper

	func configure(with tableView: UITableView) {
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
		return dataSource.item(at: indexPath).dequeueCell(from: tableView, for: indexPath)
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return dataSource.titleForHeader(inSection: section)
	}

	func tableView(_ tableView: UITableView,
	               commit editingStyle: UITableViewCellEditingStyle,
	               forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			dataSource.item(at: indexPath).deleteItem(at: indexPath)
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
		dataSource.item(at: indexPath).didSelectItem(at: indexPath)
	}
}
