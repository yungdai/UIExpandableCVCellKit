//
//  ExpandedCellViewModel.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-07.
//

import UIKit

public struct ExpandableCellViewModel {

	let originalBounds: CGRect
	let originalCenter: CGPoint
	let openedBounds: CGRect
	let openedCenter: CGPoint
	let springDamping: CGFloat
	let springVelocity: CGFloat
	let animationDuration: TimeInterval
	let scrollDirection: UICollectionView.ScrollDirection
	
	weak var expandableCVProtocol: ExpandableCVProtocol?
	
	public init(originalBounds: CGRect, originalCenter: CGPoint,
		 openedBounds: CGRect, openedCenter: CGPoint,
		 springDamping: CGFloat,
		 springVelocity: CGFloat, animationDuration: TimeInterval, expandedCellCollectionProtocol: ExpandableCVProtocol) {

		self.originalBounds = originalBounds
		self.originalCenter = originalCenter
		self.openedBounds = openedBounds
		self.openedCenter = openedCenter
		self.springDamping = springDamping
		self.springVelocity = springVelocity
		self.animationDuration = animationDuration
		self.expandableCVProtocol = expandedCellCollectionProtocol
		
		if let flowLayout = expandableCVProtocol?.collectionViewLayout as? UICollectionViewFlowLayout {
			self.scrollDirection = flowLayout.scrollDirection
		} else {
			self.scrollDirection = .vertical
		}
	}
}
