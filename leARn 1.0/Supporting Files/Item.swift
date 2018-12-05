//
//  Item.swift
//  leARn 1.0
//
//  Created by Daniel Suissa on 11/24/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import UIKit

class Item : Decodable{
    var id: Int = 0
    var label: String
    var scnFile: String
    
    required init(id: Int, label: String, scnFile: String) {
        self.id = id
        self.label = label
        self.scnFile = scnFile
        //let utf8str = image.data(using: String.Encoding.utf8)
        //self.image = utf8str!
    }
    
    required convenience init(from decoder: Decoder) throws
    {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(Int.self, forKey: .id)
        let label = try values.decode(String.self, forKey: .label)
        let scnFile = try values.decode(String.self, forKey: .scnFile)
        self.init(id: id, label: label, scnFile: scnFile)
    }
    enum CodingKeys: String, CodingKey
    {
        case scnFile
        case label
        case id
    }

}
