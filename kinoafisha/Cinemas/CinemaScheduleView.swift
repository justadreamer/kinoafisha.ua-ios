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
    @ObjectBinding var detailsProvider: ModelProvider<[ScheduleEntry]>
    
    var list: some View {
        List(detailsProvider.model!) { entry in
            if entry.type == .film {
                if entry.url != nil {
                    NavigationLink(destination: FilmDetailView(film: nil, detailsLoader: self.providersContainer.filmDetailProvider(url: entry.url!))) {
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
        LoadingView(state: $detailsProvider.loadingState) {
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
