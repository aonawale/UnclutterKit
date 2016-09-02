import UIKit

extension UIRefreshControl: ClosureSupport {}

extension UIScrollView {
	
	public func onRefresh(_ action: @escaping (UIRefreshControl) -> Void) {
		refreshControl = UIRefreshControl().then {
			$0.setAction(for: .valueChanged, callback: action)
		}
	}
}
