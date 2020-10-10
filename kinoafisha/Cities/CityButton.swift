//
//  CityButton.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CityButton: View {
    @EnvironmentObject var providersContainer: ProvidersContainer
    @Environment(\.presentationMode) var presentation
    @Binding var isPresented: Bool
    
    var city: City

    var body: some View {
        Button(action: {
            self.providersContainer.selectedCity = self.city
            self.presentation.wrappedValue.dismiss()
            self.isPresented = false
        }) {
            HStack {
                Text("\(city.name)")
                Spacer()
                if city == self.providersContainer.selectedCity {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
