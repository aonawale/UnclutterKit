import CoreData

public class FetchedResultsDataSource<Model: NSFetchRequestResult, Item> {

	public init(fetchRequest: NSFetchRequest<Model>,
	     managedObjectContext: NSManagedObjectContext,
	     tableUpdater: TableUpdatable,
	     sectionNameKeyPath: String? = nil,
	     transform: @escaping (Model) -> Item) {

		fetchedResultsController = NSFetchedResultsController<Model>(
			fetchRequest: fetchRequest,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: sectionNameKeyPath,
			cacheName: nil)
		fetchedResultsControllerDelegate = FetchedResultsControllerDelegate(
			tableUpdater: tableUpdater)
		fetchedResultsController.delegate = fetchedResultsControllerDelegate
		try! fetchedResultsController.performFetch()

		self.tableUpdater = tableUpdater
		self.transform = transform
	}

	fileprivate let fetchedResultsController: NSFetchedResultsController<Model>
	fileprivate let transform: (Model) -> Item
	private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<Model>
	private let tableUpdater: TableUpdatable
}

extension FetchedResultsDataSource: DataSourceProtocol {

	public func item(at indexPath: IndexPath) -> Item {
		return transform(fetchedResultsController.object(at: indexPath))
	}

	public func numberOfItems(inSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}

	public func numberOfSections() -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	public func titleForHeader(inSection section: Int) -> String? {
		return fetchedResultsController.sections?[section].name
	}
}
