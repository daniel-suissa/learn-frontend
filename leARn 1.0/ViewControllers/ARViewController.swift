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
    
    var timer = Timer()
    
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
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
    
    lazy var marketplaceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.setTitle("M", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.didTapM), for: .touchUpInside)
    
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "camera")!, for: .normal)
        button.addTarget(self, action: #selector(self.didTapCamera), for: .touchUpInside)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        button.layer.masksToBounds = true
        button.setTitle("R", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.didTapR), for: .touchUpInside)
        return button
    }()
    
    var text = "";
    var isLoadingWorldMap = true
    var labelingTouch = true;
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
        
        
        //set arview
        
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
        
        
        //set M button
        
        self.view.addSubview(self.marketplaceButton)
         // will return the bottommost y coordinate of the view
        
        let xPostion:CGFloat = view.frame.maxX-80
        let yPostion:CGFloat = view.frame.maxY-90
        let buttonWidth:CGFloat = 60
        let buttonHeight:CGFloat = 45
        
        self.marketplaceButton.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        self.marketplaceButton.layer.cornerRadius = 20
        self.marketplaceButton.backgroundColor = UIColor.white
        self.marketplaceButton.tintColor = UIColor.black
        self.marketplaceButton.clipsToBounds = true

        //set R button
        
        self.view.addSubview(self.resetButton)
        // will return the bottommost y coordinate of the view
        
        let rxPostion:CGFloat = view.frame.minX+40
        let ryPostion:CGFloat = view.frame.maxY-90
        let rbuttonWidth:CGFloat = 60
        let rbuttonHeight:CGFloat = 45
        
        self.resetButton.frame = CGRect(x:rxPostion, y:ryPostion, width:rbuttonWidth, height:rbuttonHeight)
        self.resetButton.layer.cornerRadius = 20
        self.resetButton.backgroundColor = UIColor.white
        self.resetButton.tintColor = UIColor.black
        self.resetButton.clipsToBounds = true
        
        self.view.addSubview(self.cameraButton)
        self.cameraButton.translatesAutoresizingMaskIntoConstraints = false;
        self.cameraButton.layer.cornerRadius = 20
        self.cameraButton.clipsToBounds = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top]-[v(45)]", options: [], metrics: nil, views: ["top": self.topLayoutGuide, "v": self.cameraButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[v(45)]-|", options: [], metrics: nil, views: ["v": self.cameraButton]))
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConfig()
    }
    
    func loadConfig() {
        // Already got a config? Run it
        if let configuration = self.sceneView.session.configuration {
            print("already got a config, running the session with it")
            self.sceneView.session.run(configuration)
        } else {
            // Create a config the first time
            print("creating config..")
            guard let worldMapData = retrieveWorldMapData(from: worldMapURL),
                let worldMap = unarchive(worldMapData: worldMapData) else { print ("can't load map"); return }
            resetTrackingConfiguration(with: worldMap)
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("checking anchor with name: \(anchor.name), current text state is: \(self.text)")
        /*guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("anchor is crapy")
            return
        }*/
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
        saveMap()
        //return createNode
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
        
        
        let hitTransform = SCNMatrix4(hitResult.worldTransform);
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        print("touch detected ", hitVector)
        print(labelingTouch)
        if placeNodeTouch {
            let anchor = ARAnchor(name: "obj;a", transform: hitResult.worldTransform)
            //let anchor = ARAnchor(for node: )
            //placeNode(position: hitVector)
            sceneView.session.add(anchor: anchor)
            
        } else if labelingTouch {
            self.textView.isHidden = false
            self.textView.becomeFirstResponder()
            labelingTouch.toggle()
        } else {
            print("placing label..")
            self.textView.isHidden = true
            //createLabel(position: hitVector, hitTransform: hitTransform)
            self.textView.resignFirstResponder()
            self.text = textView.text
            print(self.text)
            let anchor = ARAnchor(name: "label;\(self.text)", transform: hitResult.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    func placeNode(position: SCNVector3) -> SCNNode?{
        self.node.position = position
        //sceneView.scene.rootNode.addChildNode(self.node);
        self.node.scale = SCNVector3(0.1, 0.1, 0.1)
        print("placed node")
        print(self.node.name!)
        return self.node
    }
    
    func createLabel(position: SCNVector3, withText: String? = nil) -> SCNNode? {
        let text = withText ?? self.text
        let labelShape = SCNText(string: text, extrusionDepth: 0.1)
        
        labelShape.font = .systemFont(ofSize: 0.1)
        labelShape.firstMaterial!.diffuse.contents = UIColor.black
        let labelNode = SCNNode(geometry: labelShape);
        let fontSize = Float(0.1)
        labelNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        let (minVec, maxVec) = labelNode.boundingBox
        labelNode.pivot = SCNMatrix4MakeTranslation((maxVec.x + minVec.x) / 2, (maxVec.y + minVec.y) / 2, 0)
        labelNode.position = position
        
        //sceneView.scene.rootNode.addChildNode(labelNode);
    
        
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
        return labelNode
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
    
    @objc func didTapM() {
        self.resignFirstResponder()
        print("Marketplace")
        self.present(MarketplaceViewController(), animated: true, completion: nil)
    }
    
    
    struct ImageRecResponse: Decodable {
        let text: String
    }
    
    @objc func didTapCamera() {
        self.resignFirstResponder()
        print("Camera")
        guard let center = self.sceneView.realWorldPosition(for: self.sceneView.center) else { return }
        let snapshot = self.sceneView.snapshot()
        var request = URLRequest(url: URL.baseUrl.appendingPathComponent("/vision"))
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        URLSession.shared.upload(&request, data: snapshot.jpegData(compressionQuality: 0.75)) { (data, _, error) in
            guard error == nil, let data = data, let res = try? JSONDecoder().decode(ImageRecResponse.self, from: data) else {
                self.present(UIAlertController(error: error), animated: true, completion: nil)
                return
            }
            self.sceneView.scene.rootNode.addChildNode(self.createLabel(position: center, withText: res.text))
        }
    }
    
    @objc func didTapR() {
        self.resignFirstResponder()
        print("Reset")
        resetTrackingConfiguration()
        
    }
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
            print(worldMap)
        return worldMap
    }
    
    
    @objc func saveMap() {
        print("saving map...")
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return
            }
            
            do {
                try self.archive(worldMap: worldMap)
                print("map saved with: ", worldMap)
                for anchor in worldMap.anchors {
                    let node = self.sceneView.node(for: anchor)
                    print(node)
                }
            } catch {
                print("can't save map")
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            return try Data(contentsOf: self.worldMapURL)
        } catch {
            print("worldmap data cant be found")
            return nil
        }
    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        print("trying to get world map..")
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            print("world map loaded...", configuration.initialWorldMap)
            for anchor in worldMap.anchors {
                let node = sceneView.node(for: anchor)
                //print(node)
            }
        }
        print("running new session")
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
        
        
    }
}
