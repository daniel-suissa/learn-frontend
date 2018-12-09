//
//  ARViewController+SCNDelegate.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/9/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import ARKit

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("checking anchor with name: \(anchor.name ?? "unknown anchor"), current text state is: \(self.text)")
        
        
        let position = SCNVector3(x: anchor.transform.columns.3.x, y: anchor.transform.columns.3.y, z: anchor.transform.columns.3.z)
        var newNode : SCNNode?
        
        if self.text != "" {
            if placeNodeTouch {
                newNode = self.placeNode(position: position)
                node.addChildNode(newNode!)
                placeNodeTouch.toggle()
            } else if !labelingTouch {
                newNode = self.createLabel(position: position)
                node.addChildNode(newNode!)
                labelingTouch.toggle()
            }
        } else if anchor.name != nil{
            print("rendering from last session...")
            let components = anchor.name!.components(separatedBy: ";")
            print(components)
            if components[0] == "obj" {
                newNode = self.placeNode(position: position)
                node.addChildNode(newNode!)
            } else if components[0] == "label" {
                self.text = components[1]
                newNode = self.createLabel(position: position)
                node.addChildNode(newNode!)
                self.text = ""
            }
        }
        self.saveMap()
    }
    
    // MARK: touchRecognizer
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, self.lastTouchTime.timeIntervalSinceNow < -0.5 else { return }
        self.lastTouchTime = Date()
        let result = self.sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint]);
        guard let hitResult = result.last else { return }
        let hitTransform = SCNMatrix4(hitResult.worldTransform);
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        print("touch detected ", hitVector)
        print(self.labelingTouch)
        if self.placeNodeTouch {
            let anchor = ARAnchor(name: "obj;a", transform: hitResult.worldTransform)
            self.sceneView.session.add(anchor: anchor)
        } else if self.labelingTouch {
            self.textView.isHidden = false
            self.textView.becomeFirstResponder()
            self.labelingTouch.toggle()
        } else {
            print("placing label..")
            self.textView.isHidden = true
            self.textView.resignFirstResponder()
            self.text = textView.text
            print(self.text)
            let anchor = ARAnchor(name: "label;\(self.text)", transform: hitResult.worldTransform)
            self.sceneView.session.add(anchor: anchor)
        }
    }
    
}
