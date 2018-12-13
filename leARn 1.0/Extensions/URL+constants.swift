//
//  URL+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation

extension URL {
    class Base {
        static var hostString = "http://10.16.126.114"
        static var portNum = 3000
        static var url = URL(string: "\(hostString):\(portNum)")!
    }
    class API {
        static var login = URL(string: "users/login", relativeTo: Base.url)!
        static var register = URL(string: "users/register", relativeTo: Base.url)!
        static var vision = Base.url.appendingPathComponent("/vision")
        static var items = Base.url.appendingPathComponent("/items")
        static var translate = Base.url.appendingPathComponent("/translate")
    }
    class Local {
        static var baseUrl = (try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))!
        static var worldMap = baseUrl.appendingPathComponent("worldMapURL")
    }
}
