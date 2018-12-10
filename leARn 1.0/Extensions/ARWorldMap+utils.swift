//
//  ARWorldMap+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/9/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import ARKit

extension ARWorldMap {
    func archive() throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
        try data.write(to: URL.Local.worldMap, options: [.atomic])
    }
    
    static func unarchive() -> ARWorldMap? {
        guard
            let data = try? Data(contentsOf: URL.Local.worldMap),
            let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject
        else { return nil }
        print(worldMap)
        return worldMap
    }
}
