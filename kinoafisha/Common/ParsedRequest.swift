//
//  ParsedRequest.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 5/9/20.
//  Copyright © 2020 justadreamer. All rights reserved.
//

import Foundation

struct ParsedRequest: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case url
        case headers
    }

    let url: URL
    let headers: [String: String]
    
    init(url: URL) {
        self.url = url
        self.headers = [:]
    }
}

extension ParsedRequest {
    func toURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        for (k, v) in headers {
            request.addValue(v, forHTTPHeaderField: k)
        }
        return request
    }
}
