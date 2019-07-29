//
//  CityButton.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CityButton: View {
    @EnvironmentObject var providersContainer: ProvidersContainer
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
