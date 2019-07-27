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
    @State var film: Film
    //@ObjectBinding var detailsLoader: ModelProvider<Film>
    
    var body: some View {
        List {
            Section {
                FilmRow(film: film, imageHolder: providersContainer.imageHolder(for: film.thumbnailURL, defaultWidth: FilmRow.thumbWidth, defaultHeight: FilmRow.thumbHeight))
        
                NavigationLink(destination: FilmScheduleView(film: film)) {
                    Text("Расписание сеансов")
                        .foregroundColor(.accentColor)
                }
            }

            Section {
                ForEach(film.attributes, id: \.name) { attribute in
                    HStack(alignment: .top) {
                        Text("\(attribute.name)")
                            .foregroundColor(.secondary)
                        Text("\(attribute.value)")
                            .lineLimit(nil)
                    }
                }
            }
        }
    }
}
