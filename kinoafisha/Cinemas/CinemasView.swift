//
//  CinemasView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CinemasView : View {
    @ObservedObject var cinemasProvider: ModelProvider<CinemasContainer>
    @EnvironmentObject var providersContainer: ProvidersContainer

    var body: some View {
        LoadingView(state: $cinemasProvider.loadingState, isEmpty: $cinemasProvider.isEmpty) {
            VStack {
                if self.cinemasProvider.model != nil {
                    List(self.cinemasProvider.model!.cinemas, id: \.name) { cinema in
                        NavigationLink(destination: CinemaScheduleView(cinema: cinema, detailsProvider: self.providersContainer.cinemasDetailProvider(parsedRequest: cinema.detailParsedRequest))) {
                            CinemaRow(cinema: cinema, imageHolder: self.providersContainer.imageHolder(for: cinema.thumbnailURL, defaultWidth: CinemaRow.thumbWidth, defaultHeight: CinemaRow.thumbHeight))
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            self.cinemasProvider.reload()
        }
    }
}

#if DEBUG
struct CinemasView_Previews : PreviewProvider {
    static var previews: some View {
        CinemasView()
    }
}
#endif
