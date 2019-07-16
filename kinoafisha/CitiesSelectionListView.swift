//
//  CitiesListView.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CityButton: View {
    @ObjectBinding var providersContainer: ProvidersContainer
    var city: City

    var body: some View {
        Button(action: {
            self.providersContainer.selectedCity = self.city
        }) {
            HStack {
                Text("\(city.name)")
                Spacer()
                if city == self.providersContainer.selectedCity {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct CitiesSelectionListView : View {
    @ObjectBinding var providersContainer: ProvidersContainer
    @ObjectBinding var citiesProvider: ModelProvider<[City]>

    var body: some View {
        List {
            ForEach(citiesProvider.model.identified(by: \.name)) { city in
                CityButton(providersContainer: self.providersContainer, city: city)
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
