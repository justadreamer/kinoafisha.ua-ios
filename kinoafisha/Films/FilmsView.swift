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
    func filmRow(film: Film) -> FilmRow {
        FilmRow(film: film, imageHolder: self.providersContainer.imageHolder(for: film.thumbnailURL, defaultWidth: FilmRow.thumbWidth, defaultHeight: FilmRow.thumbHeight))
    }

    var body: some View {
        LoadingView(state: $filmsProvider.loadingState) {
            VStack {
                if self.filmsProvider.model != nil {
                    List(self.filmsProvider.model!, id: \.title) { film in
                        if film.detailURL != nil {
                            NavigationLink(destination: FilmDetailView(film: film, detailsLoader: self.providersContainer.filmDetailProvider(url: film.detailURL!))) {
                                self.filmRow(film: film)
                            }
                        } else {
                            self.filmRow(film: film)
                        }
                    }
                }
            }
        }
        .onAppear {
            self.filmsProvider.reload()
        }
    }
}

