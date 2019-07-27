//
//  CinemasView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CinemasView : View {
    @ObjectBinding var cinemasProvider: ModelProvider<CinemasContainer>
    @EnvironmentObject var providersContainer: ProvidersContainer

    var body: some View {
        LoadingView(state: $cinemasProvider.loadingState) {
            List(self.cinemasProvider.model.cinemas, id: \.name) { cinema in
                CinemaRow(cinema: cinema, imageHolder: self.providersContainer.imageHolder(for: cinema.thumbnailURL, defaultWidth: 160, defaultHeight: 80))
            }
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
