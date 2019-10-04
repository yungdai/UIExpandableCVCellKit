//
//  ExpandableDetailsViewController.swift
//  Pods-AppStoreAnimationDemo
//
//  Created by Yung Dai on 2019-10-02.
//

import UIKit


extension CALayer {
	/// Use this to set the CALayer to the center a parent view.
	public func setLayerToCenter(of rect: CGRect) {
		position = CGPoint(x: rect.width / 2, y: rect.height / 2)
	}
}

var isiPad: Bool {
	(UIDevice.current.userInterfaceIdiom == .pad) ? true : false
}

let detailWidthPercentage = 1 - (712 / UIScreen.main.bounds.width)
let detailHeightPercentage = 1 - (926 / UIScreen.main.bounds.height)

final public class ExpandableDetailsViewController: UIViewController {
	
	
	public var expandableDetailsViewModel: ExpandableDetailsViewModel?
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet var panGesture: UIPanGestureRecognizer!
	
	var detailView = UIView()
	var containerView = UIView()
	var animator: UIViewPropertyAnimator!
	
	// start the touch when the animation is completed
	var fractionComplete: CGFloat = 1.0
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		self.blurView.effect = nil
	}
	
	private func configureDetailView() {
		
		// start the animation then pause it to initiate the interactivity
		
		if let viewModel = expandableDetailsViewModel {
			
			detailView.backgroundColor = UIColor.white
			
			let newBounds = viewModel.detailView.convert(viewModel.detailView.bounds, to: view.coordinateSpace)
			let newCenter = viewModel.detailView.convert(viewModel.detailView.center, to: view.coordinateSpace)
			let newFrame = viewModel.detailView.convert(viewModel.detailView.frame, to: view.coordinateSpace)

			detailView.bounds = newBounds
			detailView.center = newCenter
			detailView.frame = newFrame
			detailView.layer.cornerRadius = 20
			detailView.backgroundColor = UIColor.systemPink
			detailView.autoresizesSubviews = true

			containerView = viewModel.detailView
			containerView.frame = detailView.bounds
			containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			
			// add subview first
			detailView.addSubview(containerView)
			
			// add constraints second
			detailView.addConstraints(toContainerView: containerView)
	
			view.addSubview(detailView)

			self.detailView.subviews.forEach {
				print("SubView bounds: \($0.bounds)")
				print("detailView bounds: \(self.detailView.bounds)")
				print("detailView origin: \(self.detailView.bounds.origin)")

			}
		}
	}
	
	override public func viewDidAppear(_ animated: Bool) {
		configureDetailView()
		animateIn()
	}
	

	
	private func animateIn() {

		self.containerView.layoutIfNeeded()
		animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
			
			/// required so the animation doesn't create retain cycles for the views
			[unowned self] in
			
			self.blurView.effect = UIBlurEffect(style: .dark)
			
			let detailWidthPercentage = 1 - (712 / self.view.frame.width)
			let detailHeightPercentage = 1 - (926 / self.view.frame.height)
			let detailWidth =  self.view.frame.width - (self.view.frame.width * detailWidthPercentage)
			let detailHeight = self.view.frame.height - (self.view.frame.height * detailHeightPercentage)
			
			let iPadBounds = CGRect(x: (self.view.frame.width - detailWidth) / 2, y: (self.view.frame.height - detailHeight) / 2, width: detailWidth, height: detailHeight)

			self.detailView.frame = (isiPad) ?  self.view.convert(iPadBounds, to: self.view.coordinateSpace) : self.view.frame
			self.detailView.bounds = (isiPad) ?  self.view.convert(iPadBounds, to: self.view.coordinateSpace) : self.view.bounds
			self.detailView.layoutIfNeeded()
			
			if isiPad {
				self.containerView.frame = self.detailView.bounds
			}
		}
		
		animator.startAnimation()
		animator.pausesOnCompletion = true
		
		animator.addCompletion { [unowned self] _ in
			self.animator = nil
			self.dismiss(animated: false, completion: nil)
		}
	}
	
	private func animateOut() {
		
		animator.isReversed = true
		animator.startAnimation()
		animator.pausesOnCompletion = false
	}
	
	@IBAction func gesturedScreen(_ sender: UIPanGestureRecognizer) {
		
		switch sender.state {
		case .began:
			
			// begin with what might possibly be a continuation of the current animation.
			animator.fractionComplete = fractionComplete
			fractionComplete = animator.fractionComplete
			
		case .changed:
			
			
			//			print("DetailView, width: \(String(describing: detailView.frame.width)), height: \(String(describing: detailView.frame.height))")
			//			print("iPadBounds, width: \(String(describing: iPadBounds.width)), height: \(String(describing: iPadBounds.height))")
			
			
			// set the translation into the view that you will be touching
			let translation = sender.translation(in: self.blurView)
			
			
			//			if animator.fractionComplete < 0.75 {
			//				animateOut()
			//			} else {
			
			animator.fractionComplete = (-translation.y / 100) + fractionComplete
			//			}
			
		case .ended:
			
			// when the gesture ends make sure that your record how much of the animation has been completed.
			fractionComplete = animator.fractionComplete
			
			// TODO: Add snapback logic
			
			
			break
		default:
			break
		}
		
	}
	
}


extension UIView {
	
	internal func addConstraints(toContainerView containerView: UIView) {
		
		let centerX = NSLayoutConstraint(item: containerView,
										 attribute: .centerX, relatedBy: .equal, toItem: self,
										 attribute: .centerX,
										 multiplier: 1,
										 constant: 0)
		
		let centerY = NSLayoutConstraint(item: containerView,
										 attribute: .centerY, relatedBy: .equal, toItem: self,
										 attribute: .centerY,
										 multiplier: 1,
										 constant: 0)
		
		let equalWidth = NSLayoutConstraint(item: containerView,
											attribute: .width, relatedBy: .equal, toItem: self,
											attribute: .width,
											multiplier: 1,
											constant: 0)
		
		let equalHeight = NSLayoutConstraint(item: containerView,
											 attribute: .height, relatedBy: .equal, toItem: self,
											 attribute: .height,
											 multiplier: 1,
											 constant: 0)
		
		let constraints = [centerX, centerY, equalWidth, equalHeight]

		containerView.center = self.center
		containerView.translatesAutoresizingMaskIntoConstraints = false
		
		containerView.center = self.convert(self.center, from: self.superview)
		self.addConstraints(constraints)
		NSLayoutConstraint.activate(constraints)
	}
}
