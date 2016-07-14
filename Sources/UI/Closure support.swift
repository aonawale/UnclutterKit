import UIKit

protocol ClosureSupport {}

extension ClosureSupport where Self: UIBarButtonItem {

	func setAction(callback: (Self) -> Void) {
		let _target = Target(callback: callback)
		objc_setAssociatedObject(self, &associationKey, _target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		target = _target
		action = #selector(Target.action)
	}
}

extension ClosureSupport where Self: UIControl {

	// TODO: support adding multiple actions
	func setAction(for controlEvents: UIControlEvents, callback: (Self) -> Void) {
		let target = Target(callback: callback)
		objc_setAssociatedObject(self, &associationKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		addTarget(target, action: #selector(Target.action), for: controlEvents)
	}
}

private final class Target<T: NSObject> {

	typealias Callback = (T) -> Void

	let callback: Callback

	init(callback: Callback) {
		self.callback = callback
	}

	func bridgingAction(control: T) {
		callback(control)
	}

	@objc func action(object: NSObject) {
		bridgingAction(control: object as! T)
	}
}

private var associationKey: UInt8 = 0
