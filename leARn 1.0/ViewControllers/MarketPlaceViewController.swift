//
//  MarketplaceViewController.swift
//  leARn 1.0
//
//  Created by Daniel Suissa on 11/21/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class MarketplaceViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource, URLSessionDownloadDelegate {
    
    private var node: SCNNode = SCNNode()
    private var nodeName: String = ""
    private var data: [Item] = []
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ItemCell.self, forCellReuseIdentifier: "my")
        self.view.addSubview(tableView)
        return tableView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath) as! ItemCell
        cell.item = self.data[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        //tableView().register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cellReuseIdentifier")
        super.viewDidLoad()
        print("marketplace loading")
        getItems()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func getItems() {
        let url = URL.API.items
        print(url)
        URLSession.shared.send(url: url) { [weak self] (data, response, error) in
            guard error == nil, let data = data, let itemArr = try? JSONDecoder().decode([Item].self, from: data) else {
                self?.present(UIAlertController(error: error) {
                    self?.dismiss(animated: true, completion: nil)
                }, animated: true, completion: nil)
                return
            }
            print(data)
            for item in itemArr {
                //fill in the data
                self?.data.append(item)
            }
            DispatchQueue.main.async {
                self?.tableView().reloadData()
            }
            
        }
    }
    
    @objc func didTapDownload(sender:UIButton) {
        self.resignFirstResponder()
        let scnFile = sender.accessibilityIdentifier!
        self.nodeName = scnFile
        print("Download")
        
        let url = URL.Base.url.appendingPathComponent("/\(scnFile)")
        downloadSceneTask(url: url)
        print("didn't die so...")
    }
    
    /// Downloads An SCNFile From A Remote URL
    func downloadSceneTask(url: URL){
        
        //2. Create The Download Session
        let downloadSession = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: nil)
        print("downloadTask")
        //3. Create The Download Task & Run It
        let downloadTask = downloadSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("urlSession")
        //1. Create The Filename
        let uuid = UUID().uuidString + ".scn"
        let fileURL = getDocumentsDirectory().appendingPathComponent(uuid)
        
        //2. Copy It To The Documents Directory
        do {
            try FileManager.default.copyItem(at: location, to: fileURL)
            
            print("Successfuly Saved File \(fileURL)")
            
            //3. Load The Model
            loadModel(filename: uuid)
            
        } catch {
            
            print("Error Saving: \(error)")
        }
        
    }
    
    /// Returns The Documents Directory
    ///
    /// - Returns: URL
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }
    
    /// Loads The SCNFile From The Documents Directory
    func loadModel(filename: String){
        
        //1. Get The Path Of The Downloaded File
        let downloadedScenePath = getDocumentsDirectory().appendingPathComponent(filename)
        print(downloadedScenePath)
        
        do {
            
            //2. Load The Scene Remembering The Init Takes ONLY A Local URL
            let modelScene =  try SCNScene(url: downloadedScenePath, options: nil)
            
            //3. Create A Node To Hold All The Content
            let modelHolderNode = SCNNode()
            
            //4. Get All The Nodes From The SCNFile
            let nodeArray = modelScene.rootNode.childNodes
            
            //5. Add Them To The Holder Node
            for childNode in nodeArray {
                modelHolderNode.addChildNode(childNode as SCNNode)
            }
            
            print("COUNT:")
            print(nodeArray.count)
            nodeArray[0].scale = SCNVector3(x: Float(12), y: Float(12), z: Float(12))
            print(nodeArray[0].scale)
            self.node = nodeArray[0]
            print("ARRRRRR")
            DispatchQueue.main.async {
                self.present(ARViewController(node: (self.node)), animated: true, completion: nil)
                print("Please happen last")
            }
        } catch  {
            print("Error Loading Scene")
        }
        
    }
    
}
