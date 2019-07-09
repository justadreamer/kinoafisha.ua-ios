//
//  MainView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct WelcomeDispatcherView : View {
    var citiesProvider: CitiesProvider
    @State private var presentOnBoarding = true
    var body: some View {
        Group {
            if !presentOnBoarding {
                MainTabBarView(presentSettings: $presentOnBoarding)
            } else {
                PresentableCitiesSelectionView(citiesProvider: citiesProvider, present: $presentOnBoarding)
            }
        }
        
    }
}
