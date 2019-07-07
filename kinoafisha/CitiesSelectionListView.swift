//
//  CitiesListView.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI
/*
 
struct CitySelection: SelectionManager {
    typealias SelectionValue = City?
    var citiesProvider: CitiesProvider

    mutating func select(_ value: City?) {
        citiesProvider.selectedCity = value
    }
    
    mutating func deselect(_ value: City?) {
        //noop
    }
    
    func isSelected(_ value: City?) -> Bool {
        value == citiesProvider.selectedCity
    }
}

extension CitySelection: Equatable {
    static func == (lhs: CitySelection, rhs: CitySelection) -> Bool {
        lhs.citiesProvider.selectedCity == rhs.citiesProvider.selectedCity
    }
}

extension CitySelection: Hashable {
    var hashValue: Int {
        citiesProvider.selectedCity.hashValue
    }
}
*/
struct CitiesSelectionListView : View {
    @ObjectBinding var citiesProvider: CitiesProvider
    
    var body: some View {
        List(selection: $citiesProvider.selectedCity) {
            ForEach(citiesProvider.cities.identified(by: \.name)) { city in
                Button(action: {
                    self.citiesProvider.selectedCity = city
                }) {
                    HStack {
                        Text("\(city.name)")
                        Spacer()
                        if city == self.citiesProvider.selectedCity {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CitiesListView_Previews : PreviewProvider {
    static var previews: some View {
        CitiesListView()
    }
}
#endif
