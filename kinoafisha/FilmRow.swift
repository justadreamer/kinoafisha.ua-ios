//
//  FilmRow.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct FilmRow : View {
    var film: Film
    var body: some View {
        Text(film.title)
    }
}

#if DEBUG
struct FilmRow_Previews : PreviewProvider {
    static var previews: some View {
        FilmRow()
    }
}
#endif
