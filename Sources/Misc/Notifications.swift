import Foundation

protocol NotificationProtocol {
	var name: Notification.Name { get }
}

extension NotificationProtocol where Self: RawRepresentable, Self.RawValue == String {

	var name: Notification.Name {
		return Notification.Name(rawValue)
	}
}

class NotificationManager {

	init(notificationCenter: NotificationCenter = .default) {
		self.notificationCenter = notificationCenter
	}

	deinit {
		deregisterAll()
	}

	func deregisterAll() {
		observerTokens.forEach(notificationCenter.removeObserver)
		observerTokens = []
	}

	func dumpNotifications() {
		notificationCenter.addObserver(
			forName: nil,
			object: nil,
			queue: nil) {
				print("Notification received with name: \($0.name.rawValue)")
		}
	}

	func registerObserver(forNotification notification: NotificationProtocol,
	                      object: AnyObject? = nil,
	                      block: (Notification) -> Void) {
		observerTokens.append(
			notificationCenter.addObserver(
				forName: notification.name,
				object: object,
				queue: nil,
				using: block))
	}

	private var notificationCenter: NotificationCenter
	private var observerTokens: [NSObjectProtocol] = []
}
