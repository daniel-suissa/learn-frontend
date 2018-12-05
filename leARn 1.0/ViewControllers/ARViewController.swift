//
//  ViewController.swift
//  leARn 1.0
//
//  Created by Daniel Suissa on 10/13/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: .zero)
//        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.showsStatistics = true
        return sceneView
    }()
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero);
        textView.textAlignment = .justified
        textView.backgroundColor = .lightGray
        
        // Use RGB colour
        textView.backgroundColor = UIColor(red: 39/255, green: 53/255, blue: 182/255, alpha: 1)
        
        // Update UITextView font size and colour
        textView.font = .systemFont(ofSize: 20)
        textView.textColor = .white
        
        textView.font = .boldSystemFont(ofSize: 20)
        textView.font = UIFont(name: "Verdana", size: 17)
        
        // Capitalize all characters user types
        textView.autocapitalizationType = .sentences
        
        // Make UITextView web links clickable
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        
        // Enable auto-correction and Spellcheck
        textView.autocorrectionType = .yes
        textView.spellCheckingType = .yes
        
        // Make UITextView Editable
        textView.isEditable = true
        
        // Hidden initially
        textView.isHidden = true
        return textView
    }()
    var labelingTouch = false;
    var lastTouchTime = Date()
    var node: SCNNode = SCNNode()
    var placeNodeTouch = false;
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(node: SCNNode) {
        super.init(nibName: nil, bundle: nil)
        self.node = node
        placeNodeTouch = true        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.delegate = self
        
        self.view.addSubview(self.sceneView)
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[v]|", options: [], metrics: nil, views: ["v": self.sceneView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": self.sceneView]))
//
        self.view.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[v]|", options: [], metrics: nil, views: ["v": self.textView]))
        self.view.addConstraint(.init(item: self.view, attribute: .centerY, relatedBy: .equal, toItem: self.textView, attribute: .centerY, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v(>=30)]", options: [], metrics: nil, views: ["v": self.textView]))
        
        self.sceneView.scene = SCNScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Already got a config? Run it
        if let configuration = self.sceneView.session.configuration {
            self.sceneView.session.run(configuration)
        } else {
            // Create a config the first time
            let configuration = ARWorldTrackingConfiguration()
            configuration.worldAlignment = .gravity
            configuration.planeDetection = [.horizontal, .vertical]
            
            self.sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, lastTouchTime.timeIntervalSinceNow < -0.5 else { return }
        self.lastTouchTime = Date()
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint]);
        guard let hitResult = result.last else { return }
        print("touch detected", self.lastTouchTime.timeIntervalSinceNow)
        
        let hitTransform = SCNMatrix4(hitResult.worldTransform);
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        if placeNodeTouch {
            self.textView.isHidden = true
            placeNode(position: hitVector, hitTransform: hitTransform)
            placeNodeTouch.toggle()
        } else if labelingTouch {
            self.textView.isHidden = false
            self.textView.becomeFirstResponder()
        } else {
            self.textView.isHidden = true
            createLabel(position: hitVector, hitTransform: hitTransform)
            self.textView.resignFirstResponder()
        }
        labelingTouch.toggle()
    }
    func placeNode(position: SCNVector3, hitTransform: SCNMatrix4) {
        self.node.position = position
        sceneView.scene.rootNode.addChildNode(self.node);
        self.node.scale = SCNVector3(0.1, 0.1, 0.1)
        print("placed node")
        print(self.node.name!)
    }
    
    func createLabel(position: SCNVector3, hitTransform: SCNMatrix4) {
        guard let text = textView.text, !text.isEmpty else { return }
        let labelShape = SCNText(string: text, extrusionDepth: 0.1)
        
        labelShape.font = .systemFont(ofSize: 0.1)
        labelShape.firstMaterial!.diffuse.contents = UIColor.black
        let labelNode = SCNNode(geometry: labelShape);
        let fontSize = Float(0.04)
        labelNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        let (minVec, maxVec) = labelNode.boundingBox
        labelNode.pivot = SCNMatrix4MakeTranslation((maxVec.x + minVec.x) / 2, (maxVec.y + minVec.y) / 2, 0)
        labelNode.position = position
        
        sceneView.scene.rootNode.addChildNode(labelNode);
        
        
        let w = CGFloat(maxVec.x - minVec.x)
        let h = CGFloat(maxVec.y - minVec.y)
        let d = CGFloat(maxVec.z - minVec.z)
        
        let geoBox = SCNBox(width: w, height: h, length: d, chamferRadius: 0)
        geoBox.firstMaterial!.diffuse.contents =   UIColor.white.withAlphaComponent(0.8)
        let boxNode = SCNNode(geometry: geoBox)
        boxNode.position = SCNVector3Make((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0);
        labelNode.addChildNode(boxNode)
        boxNode.position.z -= 0.05
        labelNode.addChildNode(boxNode)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y, .Z]
        labelNode.constraints = [billboardConstraint]
        boxNode.constraints = [billboardConstraint]
        
        print("creating label at \(labelNode.position)...")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func getTranslation(original: String) {
        let apiKey = "AIzaSyAaEmb95x7v0hyaH1PKekzEUesaoBZF9lU"
        
    }
}
