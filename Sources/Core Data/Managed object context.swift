import CoreData

protocol ManagedObjectContextProtocol {
	func delete(_: NSManagedObject)
	func fetch(_: NSFetchRequest<NSFetchRequestResult>) throws -> [AnyObject]
	func insertObject<O: ManagedObjectProtocol>() -> O
	func perform(_: () -> Void)
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

	func insertObject<O: ManagedObjectProtocol>() -> O {
		guard let object = NSEntityDescription.insertNewObject(
			forEntityName: O.entityName, into: self) as? O else {
				fatalError("Wrong object type")
		}
		return object
	}

	func performChanges(_ block: (NSManagedObjectContext) -> ()) {
		perform {
			block(self)
			_ = self.saveOrRollback()
		}
	}
}
