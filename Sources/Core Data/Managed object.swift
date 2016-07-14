import CoreData

protocol ManagedObjectProtocol: class {
	static var defaultFetchBatchSize: Int { get }
	static var defaultSortDescriptors: [SortDescriptor] { get }
	static var entityName: String { get }

	var managedObjectContext: NSManagedObjectContext? { get }
}

extension ManagedObjectProtocol {

	static var defaultFetchBatchSize: Int {
		return 0
	}

	static var defaultSortDescriptors: [SortDescriptor] {
		return []
	}

	static var entityName: String {
		return String(self)
	}

	static func materializedObject(in managedObjectContext: ManagedObjectContextProtocol,
	                               matching predicate: Predicate) -> Self? {
		for object in managedObjectContext.registeredObjects where !object.isFault {
			guard let result = object as? Self where predicate.evaluate(with: result) else {
				continue
			}
			return result
		}
		return nil
	}
}

extension ManagedObjectProtocol where Self: NSFetchRequestResult {

	static var fetchRequest: NSFetchRequest<Self> {
		return NSFetchRequest(entityName: entityName)
	}

	static var sortedFetchRequest: NSFetchRequest<Self> {
		return fetchRequest.then {
			$0.fetchBatchSize = defaultFetchBatchSize
			$0.sortDescriptors = defaultSortDescriptors
		}
	}

	static func findOrFetch(in managedObjectContext: NSManagedObjectContext,
	                        matchingPredicate predicate: Predicate) -> Self? {
		// Note, due to a bug in Swift 3 (Xcode 8 beta 2) a closure of type
		// `(NSFetchRequest<Self>) -> Void` (e.g. `then`) cannot be used to configure the request
		let request = fetchRequest
		request.fetchLimit = 1
		request.predicate = predicate
		request.returnsObjectsAsFaults = false

		do {
			return try materializedObject(in: managedObjectContext, matching: predicate) ??
				managedObjectContext.fetch(request).first
		} catch {
			fatalError("Error fetching object using fetchRequest: \(fetchRequest). Error: \(error).")
		}
	}

	static func findOrCreate(in managedObjectContext: NSManagedObjectContext,
	                         matchingPredicate predicate: Predicate) -> Self {
		return
			findOrFetch(in: managedObjectContext, matchingPredicate: predicate) ??
			managedObjectContext.insertObject()
	}
}

extension NSManagedObject {

	func delete(inContext context: NSManagedObjectContext? = nil) {
		(context ?? managedObjectContext)?.performChanges {
			$0.delete(self)
		}
	}

	func save(inContext context: NSManagedObjectContext? = nil) {
		(context ?? managedObjectContext)?.performChanges {
			try! $0.save()
		}
	}
}
