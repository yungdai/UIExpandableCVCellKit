//
//  ExpandedCellProtocol.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//

import UIKit

public typealias Handler = () -> Void

public protocol ExpandableCVCellProtocol: UICollectionViewCell {
	
	var originalBounds: CGRect { get set }
	var originalCenter: CGPoint { get set }
	var openedBounds: CGRect { get set }
	var openedCenter: CGPoint { get set }
	var springDamping: CGFloat { get set }
	var springVelocity: CGFloat { get set }
	var animationDuration: TimeInterval { get set }
	var dragThreshold: CGFloat { get set }
	var panGesture: UIPanGestureRecognizer { get set }
	var expandableCVProtocol: ExpandableCVProtocol? { get set }
	var scrollDirection: UICollectionView.ScrollDirection { get set }

	/**
	Optional Implimentation how you would like to handle the opening the cell
	
	- Returns: a tuple to handle the animation, completion, and boolean to animate
	```
	Example:

	let handler = {
		// handler or animation code
	}
	
	let completion = {
		// completion code
	}
	
	return (handler: handler, completion: completion, isAnimated: true)
	```
	*/
	
	func openCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
	
	/** Optional Implimentation of how you would like to handle the closing of the cell
	- Returns: a tuple to handle the animation, completion, and boolean to animate
	```
	Example:
	
	let handler = {
	// handler or animation code
	}
	
	let completion = {
	// completion code
	}
	
	return (handler: handler, completion: completion, isAnimated: true)
	```
	*/

	func closeCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
	
	/**
	Optional Implimentation of how you would like to handle the snapping back of the cell when sliding it closed
	- Returns: a tuple to handle the animation, completion, and boolean to animate
	```
	Example:
	
	let handler = {
	// handler or animation code
	}
	
	let completion = {
	// completion code
	}
	
	return (handler: handler, completion: completion, isAnimated: true)
	```
	*/
	
	func snapBackCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
}

extension ExpandableCVCellProtocol {

	public func openCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
	{ return (nil, nil, true) }
	
	public func closeCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
	{ return (nil, nil, true) }
	
	public func snapBackCellHandler() -> (handler: Handler?, completion: Handler?, isAnimated: Bool)
	{ return (nil, nil, true) }
	
	/// Set up the pan gesture in the ExpandedViewCell
	public func setupPanGesture(selector: Selector) {
		
		self.addGestureRecognizer(panGesture)
		panGesture.isEnabled = false
		panGesture.addTarget(self, action: selector)
	}
	
	/// Configure the gesturing between cell and the collection so they don't overlap with each other
	
	public func configureGesture(on focus: GestureFocus) {
		
		switch focus {
		case .onCell:
			panGesture.isEnabled = true
			expandableCVProtocol?.collectionView.isScrollEnabled = false
			
		case .onCollection:
			panGesture.isEnabled = false
			expandableCVProtocol?.collectionView.isScrollEnabled = true
		}
	}
	
	/// Configure the cell with the viewModel
	
	public func configure(with viewModel: ExpandableCellViewModel?) {
		
		guard let viewModel = viewModel else { return }
		
		originalBounds = viewModel.originalBounds
		originalCenter = viewModel.originalCenter
		openedBounds = viewModel.openedBounds
		openedCenter = viewModel.openedCenter
		springDamping = viewModel.springDamping
		springVelocity = viewModel.springVelocity
		animationDuration = viewModel.animationDuration
		expandableCVProtocol = viewModel.expandableCVProtocol
		scrollDirection = viewModel.scrollDirection
	}
	
	/// Default Implimentation to open cell
	
	public func animateCellOpen() {
		
		expandableCVProtocol?.isCellOpened = true
		expandableCVProtocol?.statusBarShoudlBeHidden = true
		configureGesture(on: .onCell)

		let animationBlock = openCellHandler()

		if animationBlock.isAnimated {
			
			guard let collectionVC = expandableCVProtocol?.collectionView else { return }
			
			UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {

				switch self.scrollDirection {
					
				case .vertical:
					
					// fixes the offset when you first start because you will have an offset -0 for y
					if collectionVC.contentOffset.y < 0 {
						collectionVC.contentOffset.y = 0
					}
					
				case .horizontal:
					
					// fixes the offset when you first start because you will have an offset -0 for x
					if collectionVC.contentOffset.x < 0 {
						collectionVC.contentOffset.x = 0
					}
					
				default:
					break
				}
				
				let currentCenterPoint = collectionVC.getCurrentCenterPoint()
				
				self.bounds = self.openedBounds
				self.center = currentCenterPoint
				
				// since you've moved you shoudl record the currentCenter point to the openedCenter
				self.openedCenter = currentCenterPoint
				
				// ensures no cells below that will overlap this cell.
				collectionVC.bringSubviewToFront(self)
				
				// run additional animations
				if let animations = animationBlock.handler {
					animations()
				}
				
				self.layoutIfNeeded()
			}, completion: { _ in

				if let completionHandler = animationBlock.completion {
					completionHandler()
				}
			})
		} else {
			noAnimationCompletion(handler: animationBlock.handler, completion: animationBlock.completion)
		}
	}
	
	/// Default implimentation to close cell
	
	public func animateCloseCell() {
		
		expandableCVProtocol?.statusBarShoudlBeHidden = false
		expandableCVProtocol?.isCellOpened = false
		configureGesture(on: .onCollection)
		
		let animationBlock = closeCellHandler()

		if animationBlock.isAnimated {
			
			UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
				
				self.bounds = self.originalBounds
				self.center = self.originalCenter
				
				if let animations = animationBlock.handler {
					animations()
				}

				self.layoutIfNeeded()
			}, completion: { _ in
				
				if let completion = animationBlock.completion {
					completion()
				}
			})
		} else {
			noAnimationCompletion(handler: animationBlock.handler, completion: animationBlock.completion)
		}
	}
	
	/// Default logic to snap the cell back when released
	
	public func animateSnapBackCell() {
	
		let animationBlock = snapBackCellHandler()

		if animationBlock.isAnimated {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
				
				self.bounds = self.openedBounds
				self.center = self.openedCenter
				
				if let animations = animationBlock.handler {
					animations()
				}
				
				self.layoutIfNeeded()
			}, completion: { _ in
				
				if let completion = animationBlock.completion {
					completion()
				}
			})
		} else {
			
			noAnimationCompletion(handler: animationBlock.handler, completion: animationBlock.completion)
		}
	}

	private func noAnimationCompletion(handler: Handler?, completion: Handler?) {
		
		if let handler = handler {
			handler()
		}
		
		if let completion = completion {
			completion()
		}
	}
	
	public func cellGesturedLogic() {

		if expandableCVProtocol?.isCellOpened ?? false {
			
			let distance = panGesture.translation(in: self).y
			
			switch panGesture.state {
			case .changed:
				
				if distance > 0 {
					if let height = expandableCVProtocol?.collectionView.bounds.height {
						
						if distance > height * dragThreshold {
							animateCloseCell()
						} else {
							dragCellLogic(panDistance: distance, collectionViewHeight: height)
						}
					}
				}
				
			case .ended:
				
				if let height = expandableCVProtocol?.collectionView.bounds.height {
					
					if distance < height * dragThreshold {
						
						animateSnapBackCell()
					}
				}
				
			default:
				break
			}
		}
	}
	
	private func dragCellLogic(panDistance distance: CGFloat, collectionViewHeight height: CGFloat) {
		
		let percentageOfHeight = distance / height
		
		let dragWidth = openedBounds.width - (openedBounds.width * percentageOfHeight)
		
		let dragHeight = openedBounds
			.height - (openedBounds.height * percentageOfHeight)
		
		let dragOriginX: CGFloat
		let dragOriginY: CGFloat
		
		// take into account if if the original center is greater than or less than the current x/y origin
		if originalCenter.x < openedCenter.x {
			
			let difference = openedCenter.x - originalCenter.x
			dragOriginX = openedCenter.x - (difference * percentageOfHeight)
		} else {
			
			let difference = originalCenter.x - openedCenter.x
			dragOriginX = openedCenter.x + (difference * percentageOfHeight)
		}
		
		if originalCenter.y < openedCenter.y {
			
			let difference = openedCenter.y - originalCenter.y
			dragOriginY = openedCenter.y - (difference * percentageOfHeight)
		} else {
			
			let difference = originalCenter.y - openedCenter.y
			dragOriginY = openedCenter.y + (difference * percentageOfHeight)
		}
		
		self.bounds = CGRect(x: dragOriginX, y: dragOriginY, width: dragWidth, height: dragHeight)
		
		// this will move the center towards where the original was
		self.center = CGPoint(x: dragOriginX, y: dragOriginY)
		
		self.layoutIfNeeded()
	}
}
