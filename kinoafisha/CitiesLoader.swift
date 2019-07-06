//
//  CitiesLoader.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

let KinoAfishaBaseURLString = "http://kinoafisha.ua"
func Q(_ s: String) -> String {
    "\"\(s)\""
}


final class CitiesLoader: BindableObject {
    var didChange = PassthroughSubject<Void, Never>()
    var isLoading: Bool = true
    var cities: [City] = []
    
    let urlSession = URLSession.init(configuration: .default)
    let url = URL(string: KinoAfishaBaseURLString)!
    let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
    
    let transformation: SkyXSLTransformation = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let xsltURL = appDelegate.s3SyncManager.url(forResource: "cities", withExtension: "xsl")!
        return SkyXSLTransformation(xslturl: xsltURL)
    }()
    
    init() {
        reload()
    }
    
    func reload() {
        var request = URLRequest(url: url)
        request.addValue(ua, forHTTPHeaderField: "User-Agent")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                if let json = try? self?.transformation.jsonObject(fromHTMLData: data, withParams: [NSString(string: "baseURL"): NSString(string: Q(KinoAfishaBaseURLString))])   {
                    print("\(json)")
                }
            }
            self?.isLoading = false
            DispatchQueue.main.async {
                self?.didChange.send(Void())
            }
        }
        task.resume()
    }
}
