//
//  Credentials.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/2/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation
import CommonCrypto

protocol Loginable {
    var email: String { get }
    var passwordHash: String { get }
}

struct User: Loginable, Codable {
    var email: String
    var passwordHash: String
    var language: String
    var displayName: String
}

fileprivate struct LoginRequest: Loginable, Encodable {
    var email: String
    var passwordHash: String
}

enum AuthenticationError: Error {
    case unknown
    case notAuthorized
}

class Credentials {
    static var main = Credentials()
    private(set) var user: User? = nil
    
    private static func passwordHash(from password: String) -> String {
        let salt = "x4vV8bGgqqmQwgCoyXFQj+(o.nUNQhVP7ND"
        return "\(password).\(salt)".data(using: .utf8)?.sha256.base64EncodedString() ?? ""
    }
    
    func login(email: String, password: String, completionHandler: ((Error?, User?) -> Void)?) {
        let passwordHash = Credentials.passwordHash(from: password)
        let auth = LoginRequest(email: email, passwordHash: passwordHash)
        var request = URLRequest(url: .loginUrl)
        request.httpMethod = "POST"
        URLSession.shared.send(&request, user: auth) { (data, response, error) in
            guard error == nil, let data = data, let user = try? JSONDecoder().decode(User.self, from: data) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                let newError = error ?? (statusCode == 401 ? AuthenticationError.notAuthorized : AuthenticationError.unknown)
                print(newError as Any)
                completionHandler?(newError, nil)
                return
            }
            Credentials.main.user = user
            completionHandler?(nil, user)
        }
    }
    
    func register(email: String, password: String, language: String, displayName: String, completionHandler: ((Error?, User?) -> Void)?) {
        let passwordHash = Credentials.passwordHash(from: password)
        let body = User(email: email, passwordHash: passwordHash, language: language, displayName: displayName).JSONEncoded
        var request = URLRequest(url: .registerUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.httpMethod = "POST"
        URLSession.shared.send(&request) { (data, response, error) in
            guard error == nil, let data = data, let user = try? JSONDecoder().decode(User.self, from: data) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                let newError = error ?? (statusCode == 401 ? AuthenticationError.notAuthorized : AuthenticationError.unknown)
                print(newError as Any)
                completionHandler?(newError, nil)
                return }
            Credentials.main.user = user
            completionHandler?(nil, user)
        }
    }
    
    private init() {} // Don't allow this class to be constructed, only a singleton
}
