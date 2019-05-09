//
//  Extensions.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//  Copyright © 2019 Yung Dai. All rights reserved.
//

import Foundation

extension UIApplication {
	
	/// Handy helper to get access to the statusBar's view
	var statusBarView: UIView? {
		guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
			return nil
		}
		return statusBarView
	}
}

extension CGFloat {
	
	/// handy helper that can be set an a CGFloat extension to make sure you get guidance for values between two numbers.
	static func returnNumberBetween(minimum smallerNumber: CGFloat, maximum largerNumber: CGFloat, inputValue value: CGFloat) -> CGFloat {
		
		let returnedFloat = minimum(largerNumber, maximum(smallerNumber, value))
		
		return returnedFloat
	}
}

extension UICollectionView {
	
	func getCurrentCenterPoint() -> CGPoint {

		var currentCenter: CGPoint = CGPoint.zero
		
		if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {

			switch flowLayout.scrollDirection {
				
			case .vertical:
				
				let currentY = center.y + contentOffset.y
				currentCenter = CGPoint(x: center.x, y: getYOffset(currentCenterY: currentY))
				
			case .horizontal:
				
				let currentX = center.x + contentOffset.x
				currentCenter = CGPoint(x: getXOffset(currentCenterX: currentX), y: center.y)
				
			@unknown default:
				fatalError("Unkown Direction")
			}
		}
		
		return currentCenter
	}
	
	func getYOffset(currentCenterY: CGFloat) -> CGFloat {
		
		// the maxY offset would be the contentSizeHeight, but at the middle of the collectView.frame.height
		let maxY = self.contentSize.height - (self.frame.height / 2)
		
		let offset = CGFloat.returnNumberBetween(minimum: 0, maximum: maxY, inputValue: currentCenterY)
		
		return offset
	}
	
	func getXOffset(currentCenterX: CGFloat) -> CGFloat {
		
		let maxX = self.contentSize.width - (self.frame.width / 2)
		
		let offset = CGFloat.returnNumberBetween(minimum: 0, maximum: maxX, inputValue: currentCenterX)
		
		return offset
	}
}
