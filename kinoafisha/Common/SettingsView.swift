//
//  SettingsView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 24/9/20.
//  Copyright © 2020 justadreamer. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var providersContainer: ProvidersContainer
    @Binding var isPresented: Bool
    @State var pushed: Bool = false //dummy to supply as isPresented to CitySelectionView
    var versionString: String {
        "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!).\(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: CitySelectionView(citiesProvider: providersContainer.citiesProvider, isPresented: $pushed).onAppear { self.pushed = true }) {
                        HStack {
                            Text("Город:")
                                .padding()
                            Text("\(providersContainer.selectedCity?.name ?? "")")
                                .fontWeight(.bold)
                                .padding()
                        }
                    }
                    #if DEBUG
                    Button("Test crash!", action: {
                        var a: Int?
                        _ = a! + 1
                    })
                    #endif
                    
                }
                HStack {
                    Text("Контент: ")
                    if #available(iOS 14.0, *) {
                        Link("kionafisha.ua", destination: URL(string: "https://kinoafisha.ua")!)
                    } else {
                        Text("kinoafisha.ua")
                    }
                }
                Text("Версия: \(versionString)")
            }
            .navigationBarTitle("Настройки")
            .navigationBarItems(trailing: Button("Закрыть", action: { isPresented = false }))
        }
    }
}

