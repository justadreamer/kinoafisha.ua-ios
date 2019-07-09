//
//  CitiesProvider.swift
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


final class CitiesProvider: BindableObject {
    var didChange = PassthroughSubject<Void, Never>()
    var isLoading: Bool = true
    var cities: [City] = []
    var selectedCity: City? {
        didSet {
            saveSelectedCity()
            notifyChanged()
        }
    }

    let userDefaults = UserDefaults.standard
    let urlSession = URLSession.init(configuration: .default)
    let url = URL(string: KinoAfishaBaseURLString+"/cinema")!
    let ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36"
    
    let transformation: SkyXSLTransformation = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let xsltURL = appDelegate.s3SyncManager.url(forResource: "cities", withExtension: "xsl")!
        return SkyXSLTransformation(xslturl: xsltURL)
    }()
    
    init() {
        maybeLoadSelectedCity()
        reload()
    }
    
    func reload() {
        var request = URLRequest(url: url)
        request.addValue(ua, forHTTPHeaderField: "User-Agent")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                if let transformed = try? self?.transformation.transformedData(fromHTMLData: data, withParams: [NSString(string: "baseURL"): NSString(string: Q(KinoAfishaBaseURLString))])   {
                    if let cities = try? JSONDecoder().decode([City].self, from: transformed) {
                        self?.cities = cities
                        if self?.selectedCity == nil {
                            self?.selectedCity = cities.first(where: { $0.isDefaultSelection })
                        }
                    }
                }
            }
            self?.isLoading = false
            self?.notifyChanged()
        }
        task.resume()
    }
    
    func notifyChanged() {
        DispatchQueue.main.async {
            self.didChange.send(())
        }
    }
    
    let selectedCityKey = "SelectedCity"
    func saveSelectedCity() {
        guard let selectedCity = selectedCity,
            let encoded = try? JSONEncoder().encode(selectedCity)//,
            //let string = String(data: encoded, encoding: .utf8)
            else { return }
        userDefaults.set(encoded, forKey: selectedCityKey)
    }
    
    func maybeLoadSelectedCity() {
        guard let data = userDefaults.value(forKey: selectedCityKey) as? Data,
            let selectedCity = try? JSONDecoder().decode(City.self, from: data)
            else { return }
        
        self.selectedCity = selectedCity
    }
}
