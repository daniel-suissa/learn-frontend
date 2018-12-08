//
//  Data+Utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    var sha256: Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(self.count), &hash)
        }
        return Data(bytes: hash)
    }
}
