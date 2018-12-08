//
//  URL+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation

extension URL {
    static var baseHost = "http://10.64.22.105"
    static var basePort = 3000
    static var baseUrl = URL(string: "\(URL.baseHost):\(URL.basePort)")!
    static var loginUrl = URL(string: "users/login", relativeTo: URL.baseUrl)!
    static var registerUrl = URL(string: "users/register", relativeTo: URL.baseUrl)!
}
