//
//  UIAlertController+error.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/8/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import UIKit

extension UIAlertController {
    convenience init(error: Error?, completion: (() -> Void)? = nil) {
        let text = error != nil ? "\(error!)" : "An unknown error occurred. Please try again."
        self.init(title: "An Error Occurred", message: text, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                completion?()
            }
        })
    }
}
