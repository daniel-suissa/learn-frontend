//
//  Item.swift
//  leARn 1.0
//
//  Created by Daniel Suissa on 11/24/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import UIKit

class Item {
    var id: Int = 0
    var label: String
    var image: UIImage
    var owner: String
    
    required init(id: Int, label: String, image: UIImage) {
        self.id = id
        self.label = label
        self.image = image
        self.owner = "owner"
        //let utf8str = image.data(using: String.Encoding.utf8)
        //self.image = utf8str!
    }
}
