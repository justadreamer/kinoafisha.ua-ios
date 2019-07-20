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

struct TabBarView : View {
    @State var presentSettings: Bool = false
    @ObjectBinding var providersContainer: ProvidersContainer

    var body: some View {
        TabbedView {
            NavigationView {
                FilmsView(filmsProvider: providersContainer.filmsProvider)
                .navigationBarTitle("Фильмы \(providersContainer.selectedCity?.name ?? "")")
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
                CinemasView(cinemasProvider: providersContainer.cinemasProvider)
                    .navigationBarTitle("Кинотеатры \(providersContainer.selectedCity?.name ?? "")")
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
        .sheet(isPresented: $presentSettings, content: modal)
    }
    
    func modal() -> some View {
        PresentableCitiesSelectionView(providersContainer: providersContainer, citiesProvider: providersContainer.citiesProvider, present: $presentSettings)
    }
}
