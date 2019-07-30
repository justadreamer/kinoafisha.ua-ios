//
//  MainTabBarView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct TabBarView : View {
    @State var presentSettings: Bool = false
    @EnvironmentObject var providersContainer: ProvidersContainer

    var body: some View {
        TabView {
            NavigationView {
                FilmsView(filmsProvider: providersContainer.filmsProvider)
                .navigationBarTitle("Фильмы \(providersContainer.selectedCity?.name ?? "")")
                .navigationBarItems(leading: ReloadButton(reload: self.providersContainer.filmsProvider.forceReload), trailing: SettingsButton(presentSettings: $presentSettings))
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
                .navigationBarItems(leading: ReloadButton(reload: self.providersContainer.cinemasProvider.forceReload), trailing: SettingsButton(presentSettings: $presentSettings))
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
        CitySelectionView(citiesProvider: providersContainer.citiesProvider, presented: $presentSettings)
            .environmentObject(providersContainer)
    }
}
