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
    @EnvironmentObject var providersContainer: ProvidersContainer

    var body: some View {
        LoadingView(state: $filmsProvider.loadingState) {
            VStack {
                if self.filmsProvider.model != nil {
                    List(self.filmsProvider.model!, id: \.title) { film in
                        NavigationLink(destination: FilmDetailView(film: film/*, detailsLoader: providersContainer.filmDetailLoader()*/)) {
                            FilmRow(film: film, imageHolder: self.providersContainer.imageHolder(for: film.thumbnailURL, defaultWidth: FilmRow.thumbWidth, defaultHeight: FilmRow.thumbHeight))
                        }
                    }
                }
            }
        }
    }
}

