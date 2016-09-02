import UIKit

final class SwitchingViewController: ViewController {

	var isPresentingA: Bool = true

	init(presentA: @escaping () -> UIViewController,
	     presentB: @escaping () -> UIViewController,
	     animationOptions: UIViewAnimationOptions = []) {
		self.presentA = presentA
		self.presentB = presentB
		self.viewAnimationOptions = animationOptions
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate let presentA: () -> UIViewController
	fileprivate let presentB: () -> UIViewController
	fileprivate let viewAnimationOptions: UIViewAnimationOptions
}

extension SwitchingViewController {

	func `switch`() {
		guard let currentChildViewController = childViewControllers.first else {
			return
		}

		let viewControllerToPresent = isPresentingA ? presentB() : presentA()
		addChildViewController(viewControllerToPresent)
		isPresentingA = !isPresentingA

		transition(
			from: currentChildViewController,
			to: viewControllerToPresent,
			duration: 0.3,
			options: viewAnimationOptions,
			animations: { _ in
				// prevent content from appearing behind navigation bar
				self.navigationController?.view.setNeedsLayout()
			},
			completion: { _ in
				currentChildViewController.removeFromParentViewController()
		})
	}
}

// UIViewController
extension SwitchingViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		presentA().then {
			$0.willMove(toParentViewController: self)
			addChildViewController($0)
			view.addSubview($0.view)
			$0.didMove(toParentViewController: self)
		}
	}
}
