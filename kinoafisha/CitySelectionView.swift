//
//  CitySelectionView.swift
//  kinoafisha
//
//  Created by eugene on 02.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CitySelectionView : View {
    @EnvironmentObject var providersContainer: ProvidersContainer
    @ObjectBinding var citiesProvider: ModelProvider<[City]>
    @Binding var presented: Bool

    var body: some View {
        NavigationView {
            LoadingView(state: $citiesProvider.loadingState) {
                List {
                    ForEach(self.providersContainer.citiesProvider.model, id: \.name) { city in
                        CityButton(city: city)
                    }
                }
            }
            .navigationBarTitle("Кинотеатры города ")
            .navigationBarItems(leading:
                ReloadButton(reload: self.providersContainer.citiesProvider.reload),
                                trailing:
                Button (action: {
                    withAnimation {
                        self.presented = false
                    }
                    self.providersContainer.delayedViewRefresh()
                }) {
                    Text("Готово")
                }
            )
        }
    }
}
