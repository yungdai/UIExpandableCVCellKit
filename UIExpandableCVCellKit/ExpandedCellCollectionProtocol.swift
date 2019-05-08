//
//  ExpandedCellCollectionProtocol.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-05-08.
//

import UIKit

public protocol ExpandedCellCollectionProtocol: UICollectionViewController {

	var statusBarShoudlBeHidden: Bool { get set}
	var isOpen: Bool { get set }
}

public enum GestureFocus {
	case onCell, onCollection
}
