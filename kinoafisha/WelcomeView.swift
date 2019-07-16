//
//  WelcomeView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct WelcomeView : View {
    @ObjectBinding var citiesProvider: CitiesProvider
    @State var presentOnboarding: Bool

    func presentableCitiesSelectionView() -> PresentableCitiesSelectionView {
        PresentableCitiesSelectionView(citiesProvider: citiesProvider, present: $presentOnboarding)
    }

    var transition: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .leading)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
    
    var body: some View {
        VStack {
            if presentOnboarding {
                presentableCitiesSelectionView()
                    .transition(transition)
            } else {
                TabBarView(citiesProvider: citiesProvider)
                    .transition(transition)
            }
        }
    }
}
