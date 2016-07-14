import UIKit

extension UIView {

	func constrain(to view: UIView, insets: UIEdgeInsets = .zero) {
		[bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
		 trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
		 view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
		 view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)]
			.forEach { $0.isActive = true }
	}
}
