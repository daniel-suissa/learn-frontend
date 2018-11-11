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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var textView: UITextView = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 0.0));
    var labelingTouch = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        //initTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func displayTextView() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        textView = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 20.0));
        textView.center = self.view.center
        textView.textAlignment = NSTextAlignment.justified
        textView.backgroundColor = UIColor.lightGray
        
        // Use RGB colour
        textView.backgroundColor = UIColor(red: 39/255, green: 53/255, blue: 182/255, alpha: 1)
        
        // Update UITextView font size and colour
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = UIColor.white
        
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.font = UIFont(name: "Verdana", size: 17)
        
        // Capitalize all characters user types
        textView.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        // Make UITextView web links clickable
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        
        // Make UITextView corners rounded
        textView.layer.cornerRadius = 10
        
        // Enable auto-correction and Spellcheck
        textView.autocorrectionType = UITextAutocorrectionType.yes
        textView.spellCheckingType = UITextSpellCheckingType.yes
        // myTextView.autocapitalizationType = UITextAutocapitalizationType.None
        
        // Make UITextView Editable
        textView.isEditable = true
        self.view.addSubview(textView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return};
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint]);
        guard let hitResult = result.last else {return};

        
        let hitTransform = SCNMatrix4(hitResult.worldTransform);
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        if labelingTouch {
            displayTextView()
        } else {
            createLabel(position: hitVector, hitTransform: hitTransform)
        }
        labelingTouch = !labelingTouch;
    }
    
    func createLabel(position: SCNVector3, hitTransform: SCNMatrix4) {
        textView.removeFromSuperview();
        let text = textView.text;
        let labelShape = SCNText(string: text, extrusionDepth: 0.1)
        //labelShape.containerFrame = CGRect(origin: CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)), size: CGSize(width: CGFloat(24.6), height: CGFloat(24.6)))
        
        
        labelShape.font   = UIFont.systemFont(ofSize: 0.1)
        //labelShape.containerFrame = CGRect(origin: .zero, size: CGSize(width: 1, height: 5))
        //labelShape.flatness = 0.005;
        //labelShape.isWrapped = true;
        //labelShape.truncationMode = kCATruncationNone
        //labelShape.alignmentMode = kCAAlignmentLeft
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
        //let ballShape = SCNSphere(radius: 0.02);
        //let ballNode = SCNNode(geometry: ballShape);
        //ballNode.position = position;
        //sceneView.scene.rootNode.addChildNode(ballNode);
        print("creating label at \(labelNode.position)...")
        //print("creating ball at \(ballNode.position)...")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
