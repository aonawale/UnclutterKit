import CoreData

public protocol ManagedObjectContextProtocol {
	func delete(_: NSManagedObject)
	func fetch(_: NSFetchRequest<NSFetchRequestResult>) throws -> [Any]
	func insertObject<O: ManagedObjectProtocol>() -> O
	func perform(_: @escaping () -> Void)
	func rollback()
	func save() throws

	var registeredObjects: Set<NSManagedObject> { get }
}

extension NSManagedObjectContext {

	func saveOrRollback() -> Bool {
		do {
			try save()
			return true
		} catch {
			print("Rolled back save because of error: \((error as NSError).localizedDescription)")
			rollback()
			return false
		}
	}
}

extension NSManagedObjectContext: ManagedObjectContextProtocol {
	public func insertObject<O: ManagedObjectProtocol>() -> O {
		guard let object = NSEntityDescription.insertNewObject(
			forEntityName: O.entityName, into: self) as? O else {
				fatalError("Wrong object type")
		}
		return object
	}

	public func performChanges(_ block: @escaping (NSManagedObjectContext) -> ()) {
		perform {
			block(self)
			_ = self.saveOrRollback()
		}
	}
}
