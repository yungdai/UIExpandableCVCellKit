//
//  ExpandableDetailsViewController.swift
//  Pods-AppStoreAnimationDemo
//
//  Created by Yung Dai on 2019-10-02.
//

import UIKit

final public class ExpandableDetailsViewController: UIViewController {
	
	public var expandedCellViewModel: ExpandableCellViewModel?
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet var panGesture: UIPanGestureRecognizer!
	
	var animator: UIViewPropertyAnimator!
	
	var progressWhenInterupted: CGFloat = 0.0

	override public func viewDidLoad() {
        super.viewDidLoad()
		
		self.blurView.effect = nil

        // Do any additional setup after loading the view.
    }
	
	override public func viewDidAppear(_ animated: Bool) {
		
		// start the animation then pause it to initiate the interactivity
		animateIn()
	}
    
	private func animateIn() {
		
		animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
			
			/// required so the animation doesn't create retain cycles for the views
			[unowned self] in
			
			self.blurView.effect = UIBlurEffect(style: .dark)
			
			
			// TODO: Add the animation of the containerView

		})
		animator.pausesOnCompletion = true
		animator.startAnimation(afterDelay: 0.0)

	}
	
	private func animateOut() {
		
		animator.finishAnimation(at: .start)
	}

	@IBAction func gesturedScreen(_ sender: UIPanGestureRecognizer) {

		switch sender.state {
            case .began:
            
            // begin with what might possibly be a continuation of the current animation.
            animator.fractionComplete = progressWhenInterupted
            progressWhenInterupted = animator.fractionComplete
            
        case .changed:
            
            // set the translation into the view that you will be touching
            let translation = sender.translation(in: self.blurView)
            
            // take the current progress and add it to the current translation to the the percentage of total animation.
            animator.fractionComplete = (translation.y / 100) + progressWhenInterupted
            
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
