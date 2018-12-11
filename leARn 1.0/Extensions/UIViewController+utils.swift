//
//  UIViewController+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/9/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    func addVFLConstraints(_ vflString: String, views: [String: UIView]) {
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vflString, options: [], metrics: nil, views: views))
    }
    
    func addVFLConstraints(_ vflStrings: [String], views: [String: UIView]) {
        vflStrings.forEach { self.addVFLConstraints($0, views: views)  }
    }
    
    func center(childView: UIView, onAxes axes: [NSLayoutConstraint.Axis]) {
        if axes.contains(.horizontal) {
            self.addConstraint(.init(item: self, attribute: .centerY, relatedBy: .equal, toItem: childView, attribute: .centerY, multiplier: 1, constant: 0))
        }
        if axes.contains(.vertical) {
            self.addConstraint(.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: childView, attribute: .centerX, multiplier: 1, constant: 0))
        }
        
    }
    
    func pinToTop(of view: UIView, safeArea: Bool = false) {
        let anchor = safeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
        self.topAnchor.constraint(equalTo: anchor).isActive = true
    }
}
