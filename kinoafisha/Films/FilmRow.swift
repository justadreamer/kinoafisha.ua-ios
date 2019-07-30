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
    @ObservedObject var imageHolder: ImageHolder

    static let thumbWidth: CGFloat = 96
    static let thumbHeight: CGFloat = 140

    var body: some View {
        HStack(alignment: .top) {
            imageHolder.imageGroup

            VStack(alignment: .leading) {
                Text(self.film.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                    .layoutPriority(1)
                
                if self.film.subtitle != nil {
                    Text(self.film.subtitle!)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .lastTextBaseline) {
                    Image(systemName: "star.fill")
                        .renderingMode(.template)
                        .foregroundColor(.yellow)
                    Text(self.film.rating)
                    Text(self.film.votesCount)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#if DEBUG
struct FilmRow_Previews : PreviewProvider {
    static var previews: some View {
        FilmRow()
    }
}
#endif
