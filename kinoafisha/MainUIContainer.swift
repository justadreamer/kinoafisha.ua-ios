//
//  MainUIContainer.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct MainUIContainer : View {
    @ObjectBinding var citiesProvider: CitiesProvider
    @State var presentSettings: Bool

    var body: some View {
        Group {
            if presentSettings {
                PresentableCitiesSelectionView(citiesProvider: citiesProvider, present: $presentSettings)
            } else {
                MainTabBarView(presentSettings: $presentSettings, city: citiesProvider.selectedCity!)
            }
        }
    }
}
