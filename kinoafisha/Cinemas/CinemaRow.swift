//
//  CinemaRow.swift
//  
//
//  Created by Eugene Dorfman on 10/7/19.
//

import SwiftUI

struct CinemaRow : View {
    static let thumbWidth: CGFloat = 160
    static let thumbHeight: CGFloat = 80

    let cinema: Cinema
    @ObservedObject var imageHolder: ImageHolder

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                imageHolder.imageGroup
                Text("\(cinema.name)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                    .layoutPriority(1)
            }
                .padding(.bottom)
            
            HStack {
                Text("Адрес:")
                    .foregroundColor(.secondary)
                Text("\(cinema.address)")
            }
            HStack(alignment: .top) {
                Text("Тел.:")
                    .foregroundColor(.secondary)
                Text("\(cinema.phone)")
                    .lineLimit(nil)
            }
        }
        
        
    }
}

#if DEBUG
struct CinemaRow_Previews : PreviewProvider {
    static var previews: some View {
        CinemaRow()
    }
}
#endif
