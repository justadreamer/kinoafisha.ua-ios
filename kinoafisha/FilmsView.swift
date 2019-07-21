//
//  FilmsView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI
import Combine

struct FilmsView : View {
    @ObjectBinding var filmsProvider: ModelProvider<[Film]>
    
    var body: some View {
        LoadingView(state: $filmsProvider.loadingState) {
            List(self.filmsProvider.model, id: \.title) { film in
                FilmRow(film: film)
            }
        }
    }
}

