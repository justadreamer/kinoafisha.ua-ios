//
//  CinemaScheduleView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 28/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CinemaScheduleView: View {
    var cinema: Cinema
    @EnvironmentObject var providersContainer: ProvidersContainer
    @ObservedObject var detailsProvider: ModelProvider<[ScheduleEntry]>
    var entries: [ScheduleEntry] {
        self.detailsProvider.model!
    }

    var list: some View {
        List(entries) { (entry: ScheduleEntry) in
            if entry.type == .film {
                if entry.detailParsedRequest != nil {
                    //TODO: cookie is lost here:
                    NavigationLink(destination: FilmDetailView(film: nil, detailsLoader: self.providersContainer.filmDetailProvider(parsedRequest: entry.detailParsedRequest!))) {
                        Text("\(entry.title)")
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                } else {
                    Text("\(entry.title)")
                        .font(.headline)
                }
            } else if entry.type == .cinemaRoom {
                VStack(alignment: .leading) {
                    Text("\(entry.title)")
                        .fontWeight(.semibold)
                    Text("\(entry.showTimes != nil ? entry.showTimes!.joined(separator: " ") : "")")
                        .foregroundColor(.red)
                }
                    .padding(.leading)
            }
        }
    }
    
    var contentView: some View {
        VStack {
            if detailsProvider.model != nil {
                self.list
            }
        }
    }

    var body: some View {
        LoadingView(state: $detailsProvider.loadingState, isEmpty: $detailsProvider.isEmpty) {
            self.contentView
        }
        .navigationBarTitle("\(cinema.name)", displayMode: .inline)
        .onAppear {
            self.detailsProvider.reload()
        }
    }
}

#if DEBUG
struct CinemaScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        CinemaScheduleView()
    }
}
#endif
