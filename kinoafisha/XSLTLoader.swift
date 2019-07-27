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

final class XSLTLoader<Model> where Model: Codable, Model: Equatable{
    var url: URL?
    var loadingState = CurrentValueSubject<LoadingState<Model>, Never>(.initial)
    private var transformation: SkyXSLTransformation
    private let urlSession = URLSession.init(configuration: .default)
    private var cancelation: AnyCancellable?

    deinit {
        cancelation?.cancel()
    }

    init(url: URL?, transformationName: String, resourceURLProvider: SkyS3ResourceURLProvider) {
        self.url = url
        self.transformation = Self.transformation(name: transformationName, from: resourceURLProvider)
    }

    static func transformation(name: String, from provider: SkyS3ResourceURLProvider) -> SkyXSLTransformation {
        let xsltURL = provider.url(forResource: name, withExtension: "xsl")!
        return SkyXSLTransformation(xslturl: xsltURL)
    }

    func reload() {
        //print("reloading \(self) url: \(String(describing: url))")
        //we could:
        //urlValue.value = urlValue.value //to stimulate a reload
        //but rather resubscribe:
        createSubscription()
    }
    
    func createSubscription() {
        cancelation?.cancel()
        guard let url = url else { return }
        self.loadingState.value = .loading
        let request = URLRequest.spoofedUA(url: url)
        cancelation =
            self.urlSession
                .dataTaskPublisher(for: request)
                .tryMap { data, response -> LoadingState<Model> in
                    //sleep(5) // for debug purposes to test loading indicator
                    //throw "shit happens" //for debug purposes to test error throwing
                    let model = try self.parse(data)
                    return LoadingState.complete(model)
                }
                .catch { error in
                    Just(LoadingState<Model>.error(error))
                }
                .subscribe(loadingState)
    }
    
    func parse(_ data: Data) throws -> Model  {
        let transformed = try transformation.transformedData(fromHTMLData: data, withParams: [NSString(string: "baseURL"): NSString(string: Q(KinoAfishaBaseURLString))])
        //for debug output:
        /*
        let jsonString = String(data: transformed, encoding: .utf8)!
        print(jsonString)
        */
        let model = try JSONDecoder().decode(Model.self, from: transformed)
        return model
    }
}

