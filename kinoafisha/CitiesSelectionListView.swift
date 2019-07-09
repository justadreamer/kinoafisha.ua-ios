//
//  CitiesListView.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CitiesSelectionListView : View {
    @ObjectBinding var citiesProvider: CitiesProvider
    
    var body: some View {
        List {
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
