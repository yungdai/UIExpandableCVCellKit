//
//  ExpandedCellCollectionProtocol.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//

import UIKit

public protocol ExpandableCVProtocol: UICollectionViewController {

	var statusBarShoudlBeHidden: Bool { get set}
	var isCellOpened: Bool { get set }
}

public enum GestureFocus {
	case onCell, onCollection
}

extension ExpandableCVProtocol {
	
	/// used to animate the duration
	public func animateStatusBar(duration: TimeInterval) {
		
		UIView.animate(withDuration: duration) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}
}
