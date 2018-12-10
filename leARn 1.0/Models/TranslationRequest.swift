//
//  TranslationRequest.swift
//  leARn 1.0
//
//  Created by Max Ainatchi on 12/9/18.
//  Copyright © 2018 Daniel Suissa. All rights reserved.
//

import Foundation

class TranslationRequest {
    static func translate(text: String, completionHandler handler: @escaping (String?) -> Void) {
        let url = URL.API.translate
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            .init(name: "text", value: text)
        ]
        URLSession.shared.send(url: components!.url!) { (data, _, error) in
            guard error == nil,
                let data = data,
                let res = try? JSONDecoder().decode(TextResponse.self, from: data)
            else { handler(nil); return }
            handler(res.text)
        }
    }
}
