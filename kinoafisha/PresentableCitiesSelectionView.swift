//
//  CitiesOnboardingView.swift
//  kinoafisha
//
//  Created by eugene on 02.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct PresentableCitiesSelectionView : View {
    @ObjectBinding var providersContainer: ProvidersContainer
    @ObjectBinding var citiesProvider: ModelProvider<[City]>
    @Binding var present: Bool

    var body: some View {
        NavigationView {
            LoadingView(isShowing: $citiesProvider.isLoading) {
                CitiesSelectionListView(providersContainer: self.providersContainer, citiesProvider: self.citiesProvider)
            }
            .navigationBarTitle("Кинотеатры города ")
            .navigationBarItems(leading:
                Button(action: {
                    self.citiesProvider.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                },
                                trailing:
                    Button(action: {
                        withAnimation {
                            self.present.toggle()
                        }
                    }) {
                        Text("Готово")
                    }
                    .disabled(citiesProvider.model.count == 0)
            )
        }
    }
}
