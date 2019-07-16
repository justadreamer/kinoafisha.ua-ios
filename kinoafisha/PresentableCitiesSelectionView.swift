//
//  CitiesOnboardingView.swift
//  kinoafisha
//
//  Created by eugene on 02.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct PresentableCitiesSelectionView : View {
    @ObjectBinding var citiesProvider: CitiesProvider
    @Binding var present: Bool

    var body: some View {
        NavigationView {
            LoadingView(isShowing: $citiesProvider.isLoading) {
                CitiesSelectionListView(citiesProvider: self.citiesProvider)
            }
            .navigationBarTitle("Кинотеатры города ")
            .navigationBarItems(trailing:
                Button(action: {
                    withAnimation {
                        self.present.toggle()
                    }
                }) {
                    Text("Готово")
                }
                .disabled(citiesProvider.cities.count == 0)
            )
        }
    }
}
