import UIKit

extension UIRefreshControl: ClosureSupport {}

extension UIScrollView {
	
	func onRefresh(_ action: (UIRefreshControl) -> Void) {
		refreshControl = UIRefreshControl().then {
			$0.setAction(for: .valueChanged, callback: action)
		}
	}
}
