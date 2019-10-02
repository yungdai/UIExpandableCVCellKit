//
//  DetailView.swift
//  UIExpandableCVCellKit
//
//  Created by Yung Dai on 2019-10-02.
//

import UIKit

class DetailView: UIView {

	
	override func layerWillDraw(_ layer: CALayer) {
		
		if let firstLayer = layer.sublayers?.first {
			
			firstLayer.bounds = self.layer.bounds
		}
	}
}
