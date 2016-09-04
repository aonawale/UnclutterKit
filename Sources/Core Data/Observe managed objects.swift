import CoreData

public enum ChangeType {
	case delete
	case update
}

public class ManagedObjectObserver {

	public init?<O: ManagedObjectProtocol>(object: O, changeHandler: @escaping (ChangeType) -> Void)
		where O: Hashable {
			guard let managedObjectContext = object.managedObjectContext else {
				return nil
			}

			notificationManager.registerObserver(
				forNotification: ManagedContextNotification.objectsDidChange,
				object: managedObjectContext) { notification in
					let changedObjects = ChangedObjects<O>(notification)
					if changedObjects.deletedObjects.contains(object) {
						changeHandler(.delete)
					} else if changedObjects.updatedObjects.contains(object) {
						changeHandler(.update)
					}
			}

	}

	private let notificationManager = NotificationManager()
}

private enum ManagedContextNotification: String, NotificationProtocol {
	case didSave = "NSManagingContextDidSaveChangesNotification"
	case willSave = "NSManagingContextWillSaveChangesNotification"

	case objectsDidChange = "NSObjectsChangedInManagingContextNotification"
}

private struct ChangedObjects<O: ManagedObjectProtocol> where O: Hashable {

	typealias S = Set<O>

	init(_ notification: Notification) {
		let managedObjectContextNotification = ManagedContextNotification(
			rawValue: notification.name.rawValue)

		assert(
			managedObjectContextNotification == .didSave ||
			managedObjectContextNotification == .objectsDidChange)
		self.notification = notification
	}

	var insertedObjects: S {
		return objects(forKey: NSInsertedObjectsKey)
	}

	var updatedObjects: S {
		return objects(forKey: NSUpdatedObjectsKey)
	}

	var deletedObjects: S {
		return objects(forKey: NSDeletedObjectsKey)
	}

	var refreshedObjects: S {
		return objects(forKey: NSRefreshedObjectsKey)
	}

	var invalidatedObjects: S {
		return objects(forKey: NSInvalidatedObjectsKey)
	}

	var invalidatedAllObjects: Bool {
		return notification.userInfo?[NSInvalidatedAllObjectsKey] != nil
	}

	var managedObjectContext: NSManagedObjectContext {
		guard let managedObjectContext = notification.object as? NSManagedObjectContext else {
			fatalError("Invalid notification object")
		}
		return managedObjectContext
	}

	let notification: Notification

	func objects(forKey key: String) -> S {
		guard let objects = notification.userInfo?[key] as? Set<NSManagedObject> else {
			return S()
		}

		return Set(objects.flatMap { $0 as? O })
	}
}
