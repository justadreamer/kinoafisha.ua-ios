//
//  MainView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct MainView : View {
    var citiesProvider: CitiesProvider
    var body: some View {
        CitiesOnboardingView(citiesProvider: citiesProvider)
    }
}
