import UIKit

public final class SwitchingViewController: ViewController {

	public var isPresentingA: Bool = true

	public init(presentA: @escaping () -> UIViewController,
	            presentB: @escaping () -> UIViewController,
	            animationOptions: UIViewAnimationOptions = []) {
		self.presentA = presentA
		self.presentB = presentB
		self.viewAnimationOptions = animationOptions
		super.init(nibName: nil, bundle: nil)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	fileprivate let presentA: () -> UIViewController
	fileprivate let presentB: () -> UIViewController
	fileprivate let viewAnimationOptions: UIViewAnimationOptions
}

extension SwitchingViewController {

	public func `switch`() {
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

	override public func viewDidLoad() {
		super.viewDidLoad()
		presentA().then {
			$0.willMove(toParentViewController: self)
			addChildViewController($0)
			view.addSubview($0.view)
			$0.didMove(toParentViewController: self)
		}
	}
}
