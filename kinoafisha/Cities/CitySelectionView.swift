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
    @ObservedObject var citiesProvider: ModelProvider<[City]>
    @Binding var isPresented: Bool
    
    var body: some View {
        LoadingView(state: $citiesProvider.loadingState) {
            VStack {
                if self.citiesProvider.model != nil {
                    List {
                        ForEach(self.citiesProvider.model!, id: \.name) { city in
                            CityButton(isPresented: $isPresented, city: city)
                        }
                    }
                }
            }
        }
        .onAppear {
            self.citiesProvider.reload()
        }
        .navigationBarTitle("Выберите город:")
    }
}
