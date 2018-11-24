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


class MarketplaceViewController: UIViewController,UITableViewDelegate ,UITableViewDataSource {
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
        getItems()
        
        
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
        }
    }
    @objc func didTapDownload(sender:UIButton) {
        self.resignFirstResponder()
        let id = sender.tag
        print("Download")
        
       
        
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
        //self.present(ARViewController(), animated: true, completion: nil)
    }
}
