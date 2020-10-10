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

    func settingsModal() -> some View {
        SettingsView(isPresented: $presentSettings)
            .environmentObject(providersContainer)
    }

    var body: some View {
        TabView {
            NavigationView {
                FilmsView(filmsProvider: providersContainer.filmsProvider)
                .navigationBarTitle("Фильмы")
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
                    .navigationBarTitle("Кинотеатры")
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
        .overlay(
            Text("\(providersContainer.selectedCity?.name ?? "")")
                    .font(.footnote),
            alignment: .top)
        .sheet(isPresented: $presentSettings, content: self.settingsModal)
    }
    
    
}
