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
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch request lacks a sort descriptor that uses sectionNameKeyPath")
        }

		self.transform = transform
	}

	fileprivate let fetchedResultsController: NSFetchedResultsController<Model>
	fileprivate let transform: (Model) -> Item
    // swiftlint:disable:next weak_delegate
	private let fetchedResultsControllerDelegate: FetchedResultsControllerDelegate<Model>
}

extension FetchedResultsDataSource: DataSourceProtocol {

	public func item(at indexPath: IndexPath) -> Item {
		return transform(fetchedResultsController.object(at: indexPath))
	}

	public func numberOfItems(inSection section: Int) -> Int {
		return fetchedResultsController.sections?[safe: section]?.numberOfObjects ?? 0
	}

	public func numberOfSections() -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	public func titleForHeader(inSection section: Int) -> String? {
		return fetchedResultsController.sections?[safe: section]?.name
	}
}
