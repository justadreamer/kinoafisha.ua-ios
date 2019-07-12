//
//  CinemasLoader.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import Combine

//just in case you want to load a transformation from bundle
extension Bundle: SkyS3ResourceURLProvider {
    
}


let KinoAfishaBaseURLString = "http://kinoafisha.ua"
func Q(_ s: String) -> String {
    "\"\(s)\""
}


final class XSLTLoader<Model: Decodable> {
    var url: URL
    var transformation: SkyXSLTransformation
    let urlSession = URLSession.init(configuration: .default)
    let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"

    var loading: Bool = false

    init(url: URL, transformation: SkyXSLTransformation) {
        self.url = url
        self.transformation = transformation
    }
    
    init(url: URL, transformationName: String, resourceURLProvider: SkyS3ResourceURLProvider) {
        self.url = url
        self.transformation = Self.transformation(name: transformationName, from: resourceURLProvider)
    }

    func reload() -> AnyPublisher<Model, Error> {
        var request = URLRequest(url: url)
        request.addValue(ua, forHTTPHeaderField: "User-Agent")
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Model in
                if let transformed = try self?.transformation.transformedData(fromHTMLData: data, withParams: [NSString(string: "baseURL"): NSString(string: Q(KinoAfishaBaseURLString))]) {
                    print("\(transformed)")
                    let model = try JSONDecoder().decode(Model.self, from: transformed)
                    print("\(model)")
                    return model
                }
                fatalError("we should not get here, either model was parsed successfully or it has thrown above") //it should not happen
            }
            .eraseToAnyPublisher()
    }
    
    static func transformation(name: String, from provider: SkyS3ResourceURLProvider) -> SkyXSLTransformation {
        let xsltURL = provider.url(forResource: name, withExtension: "xsl")!
        return SkyXSLTransformation(xslturl: xsltURL)
    }
}

