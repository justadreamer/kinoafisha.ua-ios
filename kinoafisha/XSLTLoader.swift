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

extension String: Error {
    
}

let KinoAfishaBaseURLString = "http://kinoafisha.ua"
func Q(_ s: String) -> String {
    "\"\(s)\""
}


final class XSLTLoader<Model> where Model: ProvidesEmptyState, Model: Decodable{
    var url: URL? {
        didSet {
            urlValue.send(url)
        }
    }

    private var urlValue = CurrentValueSubject<URL?, Error>(nil)
    
    var reloadModel: AnyPublisher<Model, Error> {
        print("reloading \(self) url: \(String(describing: url))")
        return urlValue
            .flatMap { url -> AnyPublisher<Model, Error> in
                //guard let url = url else { throw "no url provided" }
                guard let url = url else {
                    return Publishers.Once<Model, Error>(Model.empty)
                        .eraseToAnyPublisher()
                }
                var request = URLRequest(url: url)
                request.addValue(self.ua, forHTTPHeaderField: "User-Agent")
                return self.urlSession.dataTaskPublisher(for: request)
                    .tryMap { data, response -> Model in
                        let model = try self.parse(data)
                        return model
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    
    
    private var transformation: SkyXSLTransformation
    private let urlSession = URLSession.init(configuration: .default)
    private let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"

    var loading: Bool = false

    init(url: URL?, transformation: SkyXSLTransformation) {
        self.url = url
        self.transformation = transformation
    }
    
    init(url: URL?, transformationName: String, resourceURLProvider: SkyS3ResourceURLProvider) {
        self.url = url
        self.transformation = Self.transformation(name: transformationName, from: resourceURLProvider)
    }

    
    
    static func transformation(name: String, from provider: SkyS3ResourceURLProvider) -> SkyXSLTransformation {
        let xsltURL = provider.url(forResource: name, withExtension: "xsl")!
        return SkyXSLTransformation(xslturl: xsltURL)
    }
    
    func parse(_ data: Data) throws -> Model  {
        print("parse \(self) for url: \(url), data:\(data)")
        let transformed = try transformation.transformedData(fromHTMLData: data, withParams: [NSString(string: "baseURL"): NSString(string: Q(KinoAfishaBaseURLString))])
        let decoder = JSONDecoder()
        let model = try decoder.decode(Model.self, from: transformed)
        return model
    }
}

