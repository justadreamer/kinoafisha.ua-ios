//
//  URLRequest+Additions.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 22/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation


extension URLRequest {
    func addingSpoofedUA() -> URLRequest {
        let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
        var request = self
        request.addValue(ua, forHTTPHeaderField: "User-Agent")
        return request
    }
}
