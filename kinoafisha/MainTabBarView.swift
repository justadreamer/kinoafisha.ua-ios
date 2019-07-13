//
//  MainTabBarView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var presentSettings: Bool
    
    var body: some View {
        Button(action: {
            self.presentSettings = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

struct MainTabBarView : View {
    @Binding var presentSettings: Bool
    @ObjectBinding var citiesProvider: CitiesProvider

    var body: some View {
        TabbedView {
            NavigationView {
                FilmsView(filmsProvider: citiesProvider.filmsProvider)
                .navigationBarTitle("Фильмы")
                .navigationBarItems(trailing: SettingsButton(presentSettings: $presentSettings))
            }
            .tabItem {
                VStack {
                    Image(systemName: "film")
                    Text("Фильмы")
                }
            }
            .tag(0)

            NavigationView {
                CinemasView(cinemasProvider: citiesProvider.cinemasProvider)
                .navigationBarTitle("Кинотеатры")
                .navigationBarItems(trailing: SettingsButton(presentSettings: $presentSettings))
            }
            .tabItem {
                VStack {
                    Image(systemName: "person.2.square.stack")
                    Text("Кинотеатры")
                }
            }
            .tag(1)
        }
    }
}