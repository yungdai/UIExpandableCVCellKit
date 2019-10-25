//
//  DetailView.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-10-02.
//

import UIKit
import Foundation

class DetailView: UIView {
	override func layerWillDraw(_ layer: CALayer) {
		if let firstLayer = layer.sublayers?.first {
			firstLayer.bounds = self.layer.bounds
		}
	}
}

//extension UIVIew {
//
//	func copyView() -> AnyObject {
//
//
//	}
//}
