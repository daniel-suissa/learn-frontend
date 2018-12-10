//
//  URLSession+utils.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation

extension URLSession {
    func send(url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.send(url: url, user: nil, completionHandler: completionHandler)
    }
    
    func send(url: URL, user: Loginable?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        var request = URLRequest(url: url)
        self.send(&request, user: user, completionHandler: completionHandler)
    }
    
    func send(_ request: inout URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        self.send(&request, user: Credentials.main.user, completionHandler: completionHandler)
    }
    
    func send(_ request: inout URLRequest, user: Loginable?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        if let user = user, let authString = "\(user.email):\(user.passwordHash)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        }
        self.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completionHandler?(data, response, error)
            }
        }.resume()
    }
    
    func upload(url: URL, data: Data?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        var request = URLRequest(url: url)
        self.upload(&request, data: data, completionHandler: completionHandler)
    }
    
    func upload(_ request: inout URLRequest, data: Data?, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        if let user = Credentials.main.user, let authString = "\(user.email):\(user.passwordHash)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        }
        self.uploadTask(with: request, from: data) { (data, response, error) in
            DispatchQueue.main.async {
                completionHandler?(data, response, error)
            }
        }.resume()
    }
}
