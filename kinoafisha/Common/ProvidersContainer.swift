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

final class ProvidersContainer: ObservableObject {
    var disposeBag = Set<AnyCancellable>()
    var objectWillChange = PassthroughSubject<Void, Never>()
    let userDefaults = UserDefaults.standard

    var citiesProvider = ModelProvider<[City]>(parsedRequest: ParsedRequest(url: URL(string: KinoAfishaBaseURLString + "/cinema")!), transformationName: "cities")
    var filmsProvider = ModelProvider<[Film]>(parsedRequest: nil, transformationName: "films_v2")
    var cinemasProvider = ModelProvider<CinemasContainer>(parsedRequest: nil, transformationName: "cinemas")
    var filmProvidersMap: [ParsedRequest: ModelProvider<Film>] = [:]
    var cinemaProvidersMap: [ParsedRequest: ModelProvider<[ScheduleEntry]>] = [:]
    
    var selectedCity: City? {
        didSet {
            filmsProvider.parsedRequest = selectedCity?.requestFilm
            cinemasProvider.parsedRequest = selectedCity?.requestCinema
            filmsProvider.forceReload()
            cinemasProvider.forceReload()
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
            .compactMap { $0 }
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
            self.objectWillChange.send(())
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
            self.objectWillChange.send()
        }
    }
    
    private var imageHolders = [URL:ImageHolder]()
    func imageHolder(for url: URL?, defaultWidth: CGFloat, defaultHeight: CGFloat) -> ImageHolder {
        if let url = url, let imageHolder = imageHolders[url] {
            //print("getting imageholder for url: \(url)")
            imageHolder.reload() //whenever requested reload just in case it failed previously
            return imageHolder
        }
        //print("creating imageholder for url: \(String(describing: url))")
        let imageHolder = ImageHolder(url: url, defaultWidth: defaultWidth, defaultHeight: defaultHeight)
        if let url = url {
            imageHolders[url] = imageHolder
        }
        return imageHolder
    }

    func filmDetailProvider(parsedRequest: ParsedRequest) -> ModelProvider<Film> {
        let provider: ModelProvider<Film>
        if let p = filmProvidersMap[parsedRequest] {
            provider = p
        } else {
            provider = ModelProvider<Film>(parsedRequest: parsedRequest, transformationName: "single_film_v2")
            filmProvidersMap[parsedRequest] = provider
        }
        return provider
    }
    
    func cinemasDetailProvider(parsedRequest: ParsedRequest) -> ModelProvider<[ScheduleEntry]> {
        let provider: ModelProvider<[ScheduleEntry]>
        if let p = cinemaProvidersMap[parsedRequest] {
            provider = p
        } else {
            provider = ModelProvider<[ScheduleEntry]>(parsedRequest: parsedRequest, transformationName: "single_cinema")
            cinemaProvidersMap[parsedRequest] = provider
        }
        return provider
    }
}
