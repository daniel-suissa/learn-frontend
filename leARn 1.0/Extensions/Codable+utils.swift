//
//  Codable+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation

extension Encodable {
    var JSONEncoded: Data? {
        return try? JSONEncoder().encode(self)
    }
}
