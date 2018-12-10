//
//  ARSCNView.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/8/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import ARKit

extension ARSCNView {
    // create real world position of the point
    func realWorldPosition(for point: CGPoint) -> SCNVector3? {
        let result = self.hitTest(point, types: [.featurePoint])
        guard let hitResult = result.last else { return nil }
        let hitTransform = SCNMatrix4(hitResult.worldTransform)
        
        // m4x -> position ;; 1: x, 2: y, 3: z
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        return hitVector
    }
}
