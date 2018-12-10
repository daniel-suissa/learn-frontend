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

class ARViewController: UIViewController {
    // MARK: - views
    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.showsStatistics = true
        sceneView.delegate = self
        sceneView.scene = SCNScene()
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
    
    lazy var marketplaceButton: UIButton = {
        let button = UIButton.roundedButton()
        button.setTitle("M", for: .normal)
        button.addTarget(self, action: #selector(self.didTapM), for: .touchUpInside)
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton.roundedButton()
        button.setImage(UIImage(named: "camera")!, for: .normal)
        button.addTarget(self, action: #selector(self.didTapCamera), for: .touchUpInside)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton.roundedButton()
        button.setTitle("R", for: .normal)
        button.addTarget(self, action: #selector(self.didTapR), for: .touchUpInside)
        return button
    }()
    
    // MARK: - variables
    // TODO: Move to model
    var text = "";
    var isLoadingWorldMap = true
    var labelingTouch = true;
    var lastTouchTime = Date()
    lazy var temporaryNode: SCNNode = SCNNode()
    var placeNodeTouch = false;
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(node: SCNNode) {
        super.init(nibName: nil, bundle: nil)
        self.temporaryNode = node
        placeNodeTouch = true        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubviews([self.sceneView, self.cameraButton, self.textView, self.resetButton, self.marketplaceButton])
        
        self.view.addVFLConstraints(["|[scene]|", "V:|[scene]|"], views: ["scene": self.sceneView])
        self.view.addVFLConstraints(["|[textView]|", "V:[textView(>=30)]"], views: ["textView": self.textView])
        self.view.center(childView: self.textView, onAxes: [.horizontal])
        
        
        let buttonSize = CGSize(width: 60, height: 45)
        
        //set M button
        self.view.addVFLConstraints(["[button(\(buttonSize.width))]-\(40)-|", "V:[button(\(buttonSize.height))]-\(90)-|"], views: ["button": self.marketplaceButton])

        //set R button
        self.view.addVFLConstraints(["|-\(40)-[button(\(buttonSize.width))]", "V:[button(\(buttonSize.height))]-\(90)-|"], views: ["button": self.resetButton])
        
        self.view.addVFLConstraints(["[button(\(buttonSize.height))]-|", "V:[button(\(buttonSize.height))]"], views: ["button": self.cameraButton])
        self.cameraButton.pinToTop(of: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: - Helper functions
    func placeNode(position: SCNVector3) -> SCNNode? {
        self.temporaryNode.position = position
        //sceneView.scene.rootNode.addChildNode(self.node);
        self.temporaryNode.scale = SCNVector3(0.1, 0.1, 0.1)
        print("placed node")
        print(self.temporaryNode.name!)
        return self.temporaryNode
    }
    
    func loadConfig() {
        // Already got a config? Run it
        if let configuration = self.sceneView.session.configuration {
            print("already got a config, running the session with it")
            self.sceneView.session.run(configuration)
        } else {
            // Create a config the first time
            print("creating config..")
            guard let worldMap = ARWorldMap.unarchive() else { print ("can't load map"); return }
            self.resetTrackingConfiguration(with: worldMap)
        }
    }
    
    func createLabel(position: SCNVector3, withText: String? = nil) -> SCNNode? {
        let text = withText ?? self.text
        let labelShape = SCNText(string: "translating...", extrusionDepth: 0.1)
        
        // Substitute in the translated text when translation completes
        TranslationRequest.translate(text: text) { translated in
            guard let translated = translated else { return }
            labelShape.string = translated
        }
        
        labelShape.font = .systemFont(ofSize: 0.4)
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
    
    // MARK: - Button Actions
    @objc func didTapM() {
        self.resignFirstResponder()
        print("Marketplace")
        self.present(MarketplaceViewController(arView: self), animated: true, completion: nil)
    }
    
    @objc func didTapCamera() {
        self.resignFirstResponder()
        print("Camera")
        guard let center = self.sceneView.realWorldPosition(for: self.sceneView.center) else { return }
        let snapshot = self.sceneView.snapshot()
        var request = URLRequest(url: URL.API.vision)
        request.httpMethod = "POST"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        URLSession.shared.upload(&request, data: snapshot.jpegData(compressionQuality: 0.75)) { (data, _, error) in
            guard error == nil,
                let data = data,
                let res = try? JSONDecoder().decode(TextResponse.self, from: data),
                let label = self.createLabel(position: center, withText: res.text)
            else {
                self.present(UIAlertController(error: error), animated: true, completion: nil)
                return
            }
            self.sceneView.scene.rootNode.addChildNode(label)
        }
    }
    
    @objc func didTapR() {
        self.resignFirstResponder()
        print("Reset")
        self.resetTrackingConfiguration()
        
    }
    
    @objc func saveMap() {
        print("saving map...")
        self.sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else { return }
            do {
                try worldMap.archive()
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
    func setNode(node: SCNNode) {
        self.temporaryNode = node
        self.placeNodeTouch = true
    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        print("trying to get world map..")
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            print("world map loaded...", configuration.initialWorldMap)
        }
        print("running new session")
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            if worldMap != nil {
                for anchor in worldMap!.anchors {
                    self.sceneView.session.add(anchor: anchor)
                    print(anchor.name)
                }
            }
        })
        
        
    }
}
