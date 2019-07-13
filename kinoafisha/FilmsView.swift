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
    @ObjectBinding var filmsProvider: FilmsProvider
    
    var body: some View {
        List(filmsProvider.films.identified(by: \.title)) { film in
            FilmRow(film: film)
        }
    }
}

