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


final public class ExpandableDetailsViewController: UIViewController {
	
	public var expandableDetailsViewModel: ExpandableDetailsViewModel?
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet var panGesture: UIPanGestureRecognizer!
	
	var detailView = DetailView()
	var animator: UIViewPropertyAnimator!
	
	// start the touch when the animation is completed
	var progressWhenInterupted: CGFloat = 1.0

	override public func viewDidLoad() {
        super.viewDidLoad()

		self.blurView.effect = nil

        // Do any additional setup after loading the view.
    }
	
	override public func viewDidAppear(_ animated: Bool) {
		
		// start the animation then pause it to initiate the interactivity
		
		if let viewModel = expandableDetailsViewModel {
			
			detailView.backgroundColor = UIColor.white

			let newBounds = viewModel.detailView.convert(viewModel.detailView.bounds, to: self.view.coordinateSpace)
			
			let newCenter = viewModel.detailView.convert(viewModel.detailView.center, to: self.view.coordinateSpace)
			
			let newFrame = viewModel.detailView.convert(viewModel.detailView.frame, to: self.view.coordinateSpace)
			
			detailView.bounds = newBounds
			detailView.center = newCenter
			detailView.frame = newFrame
			detailView.layer.cornerRadius = 20
			
			viewModel.detailView.bounds = detailView.convert(viewModel.detailView.bounds, to: detailView.coordinateSpace)

			
			viewModel.detailView.layer.bounds = detailView.convert(viewModel.detailView.layer.bounds, to: self.detailView)
			
			let detailLayer = viewModel.detailView.layer
			detailLayer.frame = detailView.layer.frame
			detailLayer.needsDisplayOnBoundsChange = true

			detailView.layer.addSublayer(detailLayer)
			view.addSubview(detailView)

		}

		animateIn()
	}
    
	private func animateIn() {
		
		animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
			
			/// required so the animation doesn't create retain cycles for the views
			[unowned self] in
			
			self.blurView.effect = UIBlurEffect(style: .dark)
			
			self.detailView.bounds = self.view.coordinateSpace.bounds
			self.detailView.center = self.view.center
			self.detailView.frame = self.view.frame

			if let detailLayer = self.detailView.layer.sublayers?.first {
				
				detailLayer.bounds = self.detailView.layer.bounds
				detailLayer.frame.size.width = self.detailView.layer.bounds.size.width
				detailLayer.frame.size.height = self.detailView.layer.bounds.size.height
				detailLayer.setLayerToCenter(of: self.detailView.bounds)
				detailLayer.setNeedsDisplay()

			}
		})
		animator.startAnimation()
		animator.pausesOnCompletion = true

		animator.addCompletion({ [unowned self] (_) in
			self.animator = nil
			
			self.dismiss(animated: false, completion: nil)
		})
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
            animator.fractionComplete = progressWhenInterupted
            progressWhenInterupted = animator.fractionComplete
            
        case .changed:
			
			let detailLayer = detailView.layer.sublayers?.first!
			
			
			print("DetailLayer, width: \(detailLayer?.frame.width), height: \(detailLayer?.frame.height)")
			
			print("Layer, width: \(detailView.layer.frame.width), height: \(detailView.layer.frame.height)")
            
            // set the translation into the view that you will be touching
            let translation = sender.translation(in: self.blurView)
            
			
			if animator.fractionComplete < 0.75 {
				animateOut()
			} else {

				animator.fractionComplete = (-translation.y / 100) + progressWhenInterupted
			}
			

            
        case .ended:
            
            // when the gesture ends make sure that your record how much of the animation has been completed.
            progressWhenInterupted = animator.fractionComplete
			
			
            break
        default:
            break
        }
		
	}
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
