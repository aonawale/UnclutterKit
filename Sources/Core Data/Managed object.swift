import CoreData

public protocol ManagedObjectProtocol: class {
	static var defaultFetchBatchSize: Int { get }
	static var defaultSortDescriptors: [NSSortDescriptor] { get }
	static var entityName: String { get }

	var managedObjectContext: NSManagedObjectContext? { get }
}

public extension ManagedObjectProtocol {

	static var defaultFetchBatchSize: Int {
		return 0
	}

	static var defaultSortDescriptors: [NSSortDescriptor] {
		return []
	}

	static var entityName: String {
		return String(describing: self)
	}

	static func materializedObject(in managedObjectContext: ManagedObjectContextProtocol,
	                               matching predicate: NSPredicate) -> Self? {
		for object in managedObjectContext.registeredObjects where !object.isFault {
			guard let result = object as? Self , predicate.evaluate(with: result) else {
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

	public static var sortedFetchRequest: NSFetchRequest<Self> {
		return fetchRequest.then {
			$0.fetchBatchSize = defaultFetchBatchSize
			$0.sortDescriptors = defaultSortDescriptors
		}
	}

	static func findOrFetch(in managedObjectContext: NSManagedObjectContext,
	                        matchingPredicate predicate: NSPredicate) -> Self? {
		let request = fetchRequest.then {
			$0.fetchLimit = 1
			$0.predicate = predicate
			$0.returnsObjectsAsFaults = false
		}

		do {
			return try materializedObject(in: managedObjectContext, matching: predicate) ??
				managedObjectContext.fetch(request).first
		} catch {
			fatalError(
				"Error fetching object using fetchRequest: \(fetchRequest). Error: \(error).")
		}
	}

	public static func findOrCreate(in managedObjectContext: NSManagedObjectContext,
	                         matchingPredicate predicate: NSPredicate) -> Self {
		return
			findOrFetch(in: managedObjectContext, matchingPredicate: predicate) ??
			managedObjectContext.insertObject()
	}
}

public extension NSManagedObject {

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
