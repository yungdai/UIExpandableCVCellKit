//
//  ExpandedCellProtocol.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//

import UIKit

public typealias Handler = () -> Void

public enum ExpandableCellErrors: Error {
	
	case noViewModel
}

public protocol ExpandableCVCellProtocol: UICollectionViewCell {
	
	var panGesture: UIPanGestureRecognizer { get set }
	var viewModel: ExpandableCellViewModel? { get set }

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
		
		
		guard let viewModel = viewModel else { return }
		
		switch focus {
		case .onCell:
			panGesture.isEnabled = true
			viewModel.expandableCVProtocol?.collectionView.isScrollEnabled = false
			
		case .onCollection:
			panGesture.isEnabled = false
			viewModel.expandableCVProtocol?.collectionView.isScrollEnabled = true
		}
	}
	
	/// Configure the cell with the viewModel, this is a reqired function.
	
	public func configure(with viewModel: ExpandableCellViewModel?) throws {
		
		guard let viewModel = viewModel else { throw ExpandableCellErrors.noViewModel }
		self.viewModel = viewModel
	}
	
	/// Default Implimentation to open cell
	
	public func animateCellOpen() {
		
		guard var viewModel = viewModel else { return }
		
		viewModel.expandableCVProtocol?.isCellOpened = true
		viewModel.expandableCVProtocol?.statusBarShoudlBeHidden = true
		configureGesture(on: .onCell)

		let animationBlock = openCellHandler()

		if animationBlock.isAnimated {
			
			guard let collectionVC = viewModel.expandableCVProtocol?.collectionView else { return }
			
			UIView.animate(withDuration: TimeInterval(viewModel.animationDuration), delay: 0.0, usingSpringWithDamping: viewModel.springDamping, initialSpringVelocity: viewModel.springVelocity, options: .curveEaseInOut, animations: {

				switch viewModel.scrollDirection {
					
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
				
				self.bounds = viewModel.openedBounds
				self.center = currentCenterPoint
				
				// since you've moved you shoudl record the currentCenter point to the openedCenter
				viewModel.openedCenter = currentCenterPoint
				
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
		
		guard let viewModel = viewModel else { return }
		
		viewModel.expandableCVProtocol?.statusBarShoudlBeHidden = false
		viewModel.expandableCVProtocol?.isCellOpened = false
		configureGesture(on: .onCollection)
		
		let animationBlock = closeCellHandler()

		if animationBlock.isAnimated {
			
			UIView.animate(withDuration: viewModel.animationDuration, delay: 0.0, usingSpringWithDamping: viewModel.springDamping, initialSpringVelocity: viewModel.springVelocity, options: .curveEaseInOut, animations: {
				
				self.bounds = viewModel.originalBounds
				self.center = viewModel.originalCenter
				
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
		
		guard let viewModel = viewModel else { return }

		if animationBlock.isAnimated {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: viewModel.springDamping, initialSpringVelocity: viewModel.springVelocity, options: .curveEaseInOut, animations: {
				
				self.bounds = viewModel.openedBounds
				self.center = viewModel.openedCenter
				
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

		guard let viewModel = viewModel else { return }
		
		if viewModel.expandableCVProtocol?.isCellOpened ?? false {
			
			let distance = panGesture.translation(in: self).y
			
			switch panGesture.state {
			case .changed:
				
				if distance > 0 {
					if let height = viewModel.expandableCVProtocol?.collectionView.bounds.height {
						
						if distance > height * viewModel.dragThreshold {
							animateCloseCell()
						} else {
							dragCellLogic(panDistance: distance, collectionViewHeight: height)
						}
					}
				}
				
			case .ended:
				
				if let height = viewModel.expandableCVProtocol?.collectionView.bounds.height {
					
					if distance < height * viewModel.dragThreshold {
						
						animateSnapBackCell()
					}
				}
				
			default:
				break
			}
		}
	}
	
	private func dragCellLogic(panDistance distance: CGFloat, collectionViewHeight height: CGFloat) {
		
		guard let viewModel = viewModel else { return }
		
		let percentageOfHeight = distance / height
		
		let dragWidth = viewModel.openedBounds.width - (viewModel.openedBounds.width * percentageOfHeight)
		
		let dragHeight = viewModel.openedBounds
			.height - (viewModel.openedBounds.height * percentageOfHeight)
		
		let dragOriginX: CGFloat
		let dragOriginY: CGFloat
		
		// take into account if if the original center is greater than or less than the current x/y origin
		if viewModel.originalCenter.x < viewModel.openedCenter.x {
			
			let difference = viewModel.openedCenter.x - viewModel.originalCenter.x
			dragOriginX = viewModel.openedCenter.x - (difference * percentageOfHeight)
		} else {
			
			let difference = viewModel.originalCenter.x - viewModel.openedCenter.x
			dragOriginX = viewModel.openedCenter.x + (difference * percentageOfHeight)
		}
		
		if viewModel.originalCenter.y < viewModel.openedCenter.y {
			
			let difference = viewModel.openedCenter.y - viewModel.originalCenter.y
			dragOriginY = viewModel.openedCenter.y - (difference * percentageOfHeight)
		} else {
			
			let difference = viewModel.originalCenter.y - viewModel.openedCenter.y
			dragOriginY = viewModel.openedCenter.y + (difference * percentageOfHeight)
		}
		
		self.bounds = CGRect(x: dragOriginX, y: dragOriginY, width: dragWidth, height: dragHeight)
		
		// this will move the center towards where the original was
		self.center = CGPoint(x: dragOriginX, y: dragOriginY)
		
		self.layoutIfNeeded()
	}
}
