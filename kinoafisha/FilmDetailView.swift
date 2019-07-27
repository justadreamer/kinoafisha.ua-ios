//
//  FilmDetailView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 27/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct FilmDetailView: View {
    @EnvironmentObject var providersContainer: ProvidersContainer
    var film: Film
    @ObjectBinding var detailsLoader: ModelProvider<Film>
    @State var loading: Bool = false
    
    var enrichedFilm : Film {
        detailsLoader.model == nil ? film : detailsLoader.model!
    }

    var body: some View {
        List {
            headingSection()
            enrichedFilmSection()
            activityIndicator()
        }
            .onAppear {
                self.detailsLoader.reload()
            }
            .navigationBarTitle(Text("\(film.title)"), displayMode: .inline)
    }
    
    func headingSection() -> some View {
        Section {
            FilmRow(film: film, imageHolder: providersContainer.imageHolder(for: film.thumbnailURL, defaultWidth: FilmRow.thumbWidth, defaultHeight: FilmRow.thumbHeight))

            NavigationLink(destination: FilmScheduleView(film: film)) {
                Text("Расписание сеансов")
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    func enrichedFilmSection() -> some View {
        Section {
            ForEach(enrichedFilm.attributes, id: \.name) { attribute in
                HStack(alignment: .top) {
                    Text("\(attribute.name)")
                        .foregroundColor(.secondary)
                    Text("\(attribute.value)")
                        .lineLimit(nil)
                }
            }
        }
    }

    func activityIndicator() -> some View {
        HStack {
            Spacer()
            ActivityIndicator(isAnimating: $loading, style: .medium)
            Spacer()
        }
        .onReceive(detailsLoader.willChange) {
            self.loading = self.detailsLoader.loadingState == .loading
        }
    }
}
