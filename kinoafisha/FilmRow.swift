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
    @ObjectBinding var imageHolder: ImageHolder

    static let thumbWidth: Length = 96
    static let thumbHeight: Length = 140

    var body: some View {
        HStack(alignment: .top) {
            Group {
                if imageHolder.image != nil {
                    imageHolder.image
                    .transition(.opacity)
                } else {
                    imageHolder.defaultImage
                }
            }
            .frame(width: imageHolder.width, height: imageHolder.height)

            VStack(alignment: .leading) {
                Text(self.film.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                    .layoutPriority(1)

                Text(self.film.subtitle)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)

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
