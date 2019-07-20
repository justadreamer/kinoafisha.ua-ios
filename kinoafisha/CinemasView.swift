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
    var body: some View {
        LoadingView(isShowing: $cinemasProvider.isLoading) {
            List(self.cinemasProvider.model.cinemas, id: \.name) { cinema in
                CinemaRow(cinema: cinema)
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
