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
    var film: Film?
    @ObservedObject var detailsLoader: ModelProvider<Film>
    @State var loading: Bool = false
    
    var enrichedFilm : Film? {
        //print(detailsLoader.model)
        return detailsLoader.model ?? film
    }

    var scheduleText: Text {
        Text("Расписание сеансов")
    }

    func content() -> some View {
        List {
            headingSection(film: enrichedFilm)
            scheduleSection()
            enrichedFilmSection()
            activityIndicator()
        }
        .navigationBarTitle(Text("\(enrichedFilm == nil ? "" : enrichedFilm!.title)"), displayMode: .inline)
    }
    
    var body: some View {
        Group {
            if self.enrichedFilm == nil {
                LoadingView(state: $detailsLoader.loadingState, isEmpty: $detailsLoader.isEmpty, content: content)
            } else {
                content()
            }
        }
        .onAppear {
            self.detailsLoader.reload()
        }
            
    }

    func headingSection(film: Film?) -> some View {
        Group {
            if film != nil {
                Section {
                    FilmRow(film: film!, imageHolder: providersContainer.imageHolder(for: film!.thumbnailURL, defaultWidth: FilmRow.thumbWidth, defaultHeight: FilmRow.thumbHeight))
                }
            }
        }
    }
    
    func scheduleSection() -> some View {
        Section {
            if enrichedFilm != nil && enrichedFilm!.scheduleEntries != nil {
                NavigationLink(destination: FilmScheduleView(scheduleEntries: enrichedFilm!.scheduleEntries!)) {
                    scheduleText
                        .foregroundColor(.accentColor)
                }
            } else {
                scheduleText
            }
        }
    }
    
    func enrichedFilmSection() -> some View {
        Group {
            if enrichedFilm != nil {
                Section {
                    ForEach(enrichedFilm!.attributes, id: \.name) { attribute in
                        HStack(alignment: .top) {
                            Text("\(attribute.name)")
                                .foregroundColor(.secondary)
                            Text("\(attribute.value)")
                                .lineLimit(nil)
                        }
                    }
                    if enrichedFilm!.descr != nil {
                        Text("\(enrichedFilm!.descr!)")
                            .lineLimit(nil)
                    }
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
        .onReceive(detailsLoader.objectWillChange) {
            //print("\(self.detailsLoader.loadingState)")
            //self.loading = self.detailsLoader.loadingState == .loading
        }
    }
}
