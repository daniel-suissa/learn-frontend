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
//import Alamofire
//import SwiftyJSON

var localhost = "http://192.168.1.3"
var port = ":3000"

class MarketplaceViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource, URLSessionDownloadDelegate {
    
    private var node: SCNNode = SCNNode()
    private var nodeName: String = ""
    private var data: [Item] = []
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
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
        
        let url = URL(string: "\(localhost)\(port)/items/")!
        print(url)
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data else { return }
            print(data)
            let itemArr = try? JSONDecoder().decode([Item].self, from: data)
            for  item: Item in itemArr! {
                //fill in the data
                self?.data.append(item)
                //let imgData = try item["img"].rawData() as Data?
                /*if imgData != nil {
                    let img = UIImage()
                    self.data.append(Item(id: subJson["id"].intValue as Int, label: subJson["label"].stringValue, image: img))
                }*/
            }
            DispatchQueue.main.async {
                self?.tableView().reloadData()
            }
            
        }
        
        
        task.resume()
        
        /*
        let url = "http://localhost:3000/items"
        Alamofire.request(url)
            .responseJSON {
                response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET")
                    print(response.result.error!)
                    return
                }
                let json = JSON(response.result.value)
                for (index,subJson):(String, JSON) in json {
                    //fill in the data
                    do {
                        let imgData = try subJson["img"].rawData() as Data?
                        if imgData != nil {
                            let img = UIImage()
                            self.data.append(Item(id: subJson["id"].intValue as Int, label: subJson["label"].stringValue, image: img))
                        }
                    } catch {
                        print("conversion error")
                    }
                }
                print(self.data)
                self.tableView().reloadData()
        }*/
    }
    @objc func didTapDownload(sender:UIButton) {
        self.resignFirstResponder()
        let scnFile = sender.accessibilityIdentifier!
        self.nodeName = scnFile
        print("Download")
        
       
        let urlStr = "\(localhost)\(port)/\(scnFile)";
        print(urlStr)
        let url = URL(string: urlStr)!
        downloadSceneTask(url: url)
        print("didn't die so...")
        //let scene = try! SCNScene(url: url as URL, options:nil)
        //self.present(ARViewController(scene: scene), animated: true, completion: nil)
        /*
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data else { return }
            let scnSource = SCNSceneSource(data: data)
            DispatchQueue.main.async {
                self?.present(ARViewController(sceneSource: scnSource!), animated: true, completion: nil)
            }
            
        }
        
        task.resume()*/
        
        /*
        let url = "http://localhost:3000/items/\(id)"
        Alamofire.request(url)
            .responseJSON {
                response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET")
                    print(response.result.error!)
                    return
                }
                let json = JSON(response.result.value)
                print(json)
                do {
                    let fileData = try json["file"].rawData() as Data?
                    if fileData != nil {
                        print("data!")
                    }
                } catch {
                    print("conversion error")
                }
                print(self.data)
                self.tableView().reloadData()
        }
 */
        //self.present(ARViewController(), animated: true, completion: nil)
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
