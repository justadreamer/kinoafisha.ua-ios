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

final class ProvidersContainer: BindableObject {
    var disposeBag = Set<AnyCancellable>()
    var didChange = PassthroughSubject<Void, Never>()
    let userDefaults = UserDefaults.standard

    var citiesProvider = ModelProvider<[City]>(url: URL(string: KinoAfishaBaseURLString + "/cinema"), transformationName: "cities")
    var filmsProvider = ModelProvider<[Film]>(url: nil, transformationName: "films")
    var cinemasProvider = ModelProvider<CinemasContainer>(url: nil, transformationName: "cinemas")

    var selectedCity: City? {
        didSet {
            filmsProvider.url = selectedCity?.filmURL
            cinemasProvider.url = selectedCity?.cinemaURL
            saveSelectedCity()
            notifyChanged()
        }
    }

    deinit {
        disposeBag.forEach( { $0.cancel() })
    }

    init() {
        maybeLoadSelectedCity()
        citiesProvider
            .didChange
            .map { cities in
                cities.first(where: { $0.isDefaultSelection })
            }
            .assign(to: \.selectedCity, on: self)
            .store(in: &disposeBag)
    }
    
    func notifyChanged() {
        DispatchQueue.main.async {
            self.didChange.send(())
        }
    }
    
    private let selectedCityKey = "SelectedCity"
    func saveSelectedCity() {
        guard let selectedCity = selectedCity,
            let encoded = try? JSONEncoder().encode(selectedCity)//,
            //let string = String(data: encoded, encoding: .utf8)
            else {
                userDefaults.removeObject(forKey: selectedCityKey)
                return
            }
        userDefaults.set(encoded, forKey: selectedCityKey)
    }
    
    func maybeLoadSelectedCity() {
        guard let data = userDefaults.value(forKey: selectedCityKey) as? Data,
            let selectedCity = try? JSONDecoder().decode(City.self, from: data)
            else { return }
        
        self.selectedCity = selectedCity
    }
}
