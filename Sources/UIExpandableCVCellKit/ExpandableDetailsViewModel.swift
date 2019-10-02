//
//  ExpandableDetailsViewModel.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-10-02.
//

import UIKit

public struct ExpandableDetailsViewModel {
	
	public let originalBounds: CGRect
	public let originalCenter: CGPoint
	public let detailView: UIView
	public let indexPath: IndexPath
	
	public init(originalBounds: CGRect, originalCenter: CGPoint, detailView: UIView, indexPath: IndexPath) {
		self.originalBounds = originalBounds
		self.originalCenter = originalCenter
		self.detailView = detailView
		self.indexPath = indexPath
	}
}
