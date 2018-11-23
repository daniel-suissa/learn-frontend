//
//  MarketplaceViewController.swift
//  leARn 1.0
//
//  Created by Daniel Suissa on 11/21/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class arItem {
    var id: Int = 0
    var label: String
    var imageUrl: String
    
    required init(json: [String: Any]) {
        self.id = json["id"] as! Int
        self.label = json["label"] as! String
        self.imageUrl = json["imageUrl"] as! String
    }
    
}

class MarketplaceViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource {
    private var data: [String] = []
    lazy var tableView = { () -> UITableView in
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "my")
        self.view.addSubview(tableView)
        return tableView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "my", for: indexPath)
        let text = self.data[indexPath.row]
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        //tableView().register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cellReuseIdentifier")
        print("did load")
        super.viewDidLoad()
        
        getItems()
        
        for i in 0...5 {
            data.append("\(i)")
        }
        
        self.tableView().reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getItems() {
        let url = "http://localhost:3000/items"
        
        
        Alamofire.request(url)
            .responseJSON {
                response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /todos/1")
                    print(response.result.error!)
                    return
                }
                let json = JSON(response.result.value)
                
                for (index,subJson):(String, JSON) in json {
                    print(subJson["id"])
                }
        }
    }
}
