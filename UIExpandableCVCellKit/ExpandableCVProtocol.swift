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
	
	/// Used to animate status bar for a set the duration
	public func animateStatusBar(duration: TimeInterval) {
		
		UIView.animate(withDuration: duration) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}

	@discardableResult
	/// Use this function inside collectionView(_ collectionView:, didSelectItemAt indexPath:) to ensure that the cell opens when tapped.  This implimentation is mandatory
	public func animateCellOpen(indexPath: IndexPath) -> ExpandableCVCellProtocol? {
		
		guard let cell = collectionView.cellForItem(at: indexPath) as? ExpandableCVCellProtocol else { return nil }
		
		if !isCellOpened {
			
			cell.animateCellOpen()
		}
		
		return cell
	}
}




