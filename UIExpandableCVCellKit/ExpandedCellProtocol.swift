//
//  ExpandedCellProtocol.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//

import UIKit

public protocol ExpandedCellProtocol: UICollectionViewCell {
	
	var originalBounds: CGRect { get set }
	var originalCenter: CGPoint { get set }
	var openedBounds: CGRect { get set }
	var openedCenter: CGPoint { get set }
	var springDamping: CGFloat { get set }
	var springVelocity: CGFloat { get set }
	var animationDuration: TimeInterval { get set }
	var dragThreshold: CGFloat { get set }
	var panGesture: UIPanGestureRecognizer { get set }
	var expandedCellCollectionProtocol: ExpandedCellCollectionProtocol? { get set }
	
	func openCell()
	func closeCell()
	func snapBackCell()
}

extension ExpandedCellProtocol {
	
	/// Used to set up the pan gesture in the ExpandedViewCell
	public func setupPanGesture(selector: Selector) {
		
		self.addGestureRecognizer(panGesture)
		panGesture.isEnabled = false
		panGesture.addTarget(self, action: selector)
	}
	
	public func configureGesture(on focus: GestureFocus) {
		
		switch focus {
		case .onCell:
			panGesture.isEnabled = true
			expandedCellCollectionProtocol?.collectionView.isScrollEnabled = false
			
		case .onCollection:
			panGesture.isEnabled = false
			expandedCellCollectionProtocol?.collectionView.isScrollEnabled = true
		}
	}
	
	/// Configure the cell with the viewModel
	public func configure(with viewModel: ExpandedCellViewModel?) {
		
		guard let viewModel = viewModel else { return }
		
		originalBounds = viewModel.originalBounds
		originalCenter = viewModel.originalCenter
		openedBounds = viewModel.openedBounds
		openedCenter = viewModel.openedCenter
		springDamping = viewModel.springDamping
		springVelocity = viewModel.springVelocity
		animationDuration = viewModel.animationDuration
		expandedCellCollectionProtocol = viewModel.expandedCellCollectionProtocol
	}
	
	/// optional: generic implimentation to open cell
	public func animateCellOpenLogic() {
		
		expandedCellCollectionProtocol?.isOpen = true
		expandedCellCollectionProtocol?.statusBarShoudlBeHidden = true
		configureGesture(on: .onCell)
		
		guard let collectionVC = expandedCellCollectionProtocol?.collectionView else { return }
		
		UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
			
			// fixes the offset when you first start because you will have an offset -0 for y
			if collectionVC.contentOffset.y < 0 {
				collectionVC.contentOffset.y = 0
			}
			
			let currentCenterPoint = collectionVC.getCurrentCenterPoint()
			
			self.bounds = collectionVC.bounds
			self.center = currentCenterPoint
			
			// since you've moved you shoudl record the currentCenter point to the openedCenter
			self.openedCenter = currentCenterPoint
			
			// ensures no cells below that will overlap this cell.
			collectionVC.bringSubviewToFront(self)
			self.layoutIfNeeded()
		})
	}
	
	/// optional: generic implimentation to close cell
	public func closeCellLogic() {
		
		expandedCellCollectionProtocol?.statusBarShoudlBeHidden = false
		expandedCellCollectionProtocol?.isOpen = false
		configureGesture(on: .onCollection)
		
		UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
			
			self.bounds = self.originalBounds
			self.center = self.originalCenter
			
			self.layoutIfNeeded()
		})
	}
	
	/// optional: used to snap the cell back when released
	public func snapBackLogic() {
		
		UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: springDamping, initialSpringVelocity: springVelocity, options: .curveEaseInOut, animations: {
			
			self.bounds = self.openedBounds
			self.center = self.openedCenter
			
			self.layoutIfNeeded()
		})
	}
	
	public func cellGesturedLogic() {

		if expandedCellCollectionProtocol?.isOpen ?? false {
			
			let distance = panGesture.translation(in: self).y
			
			switch panGesture.state {
			case .changed:
				
				if distance > 0 {
					if let height = expandedCellCollectionProtocol?.collectionView.bounds.height {
						
						if distance > height * dragThreshold {
							closeCell()
						} else {
							dragCellLogic(panDistance: distance, collectionViewHeight: height)
						}
					}
				}
				
			case .ended:
				
				if let height = expandedCellCollectionProtocol?.collectionView.bounds.height {
					
					if distance < height * dragThreshold {
						
						snapBackCell()
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
