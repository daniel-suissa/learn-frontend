//
//  UIButton+styling.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/9/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import UIKit

extension UIButton {
    static func roundedButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.tintColor = .black
        button.setTitleColor(.blue, for: .normal)
        return button
    }
}
