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
    var willChange = PassthroughSubject<Void, Never>()
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
            .modelValue
            .filter { [weak self] _ in self?.selectedCity == nil }
            .map { cities in
                let city = cities.first(where: { $0.isDefaultSelection })
                print("\(String(describing: city))")
                return city
            }
            .assign(to: \.selectedCity, on: self)
            .store(in: &disposeBag)
    }

    func notifyChanged() {
        DispatchQueue.main.async {
            self.willChange.send(())
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
    
    func delayedViewRefresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(500))) {
            self.willChange.send()
        }
    }
    
    private var imageHolders = [URL:ImageHolder]()
    func imageHolder(for url: URL, defaultWidth: Length, defaultHeight: Length) -> ImageHolder {
        if let imageHolder = imageHolders[url] {
            imageHolder.reload() //whenever requested reload just in case it failed previously
            return imageHolder
        }
        let imageHolder = ImageHolder(url: url, defaultWidth: defaultWidth, defaultHeight: defaultHeight)
        imageHolders[url] = imageHolder
        return imageHolder
    }
    /*
    func filmDetailProvider(url: URL) -> ModelProvider<Film> {
        return ModelProvider<Film>(url: url, transformationName: "single_filmv2")
    }*/
}
