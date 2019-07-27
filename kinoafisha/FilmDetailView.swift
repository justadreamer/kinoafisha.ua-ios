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

    var scheduleText: Text {
        Text("Расписание сеансов")
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
            
            if enrichedFilm.scheduleEntries != nil {
                NavigationLink(destination: FilmScheduleView(scheduleEntries: enrichedFilm.scheduleEntries!)) {
                    scheduleText
                        .foregroundColor(.accentColor)
                }
            } else {
                scheduleText
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
            if enrichedFilm.descr != nil {
                Text("\(enrichedFilm.descr!)")
                    .lineLimit(nil)
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
