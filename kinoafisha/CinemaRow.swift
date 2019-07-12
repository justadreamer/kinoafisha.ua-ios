//
//  CinemaRow.swift
//  
//
//  Created by Eugene Dorfman on 10/7/19.
//

import SwiftUI

struct CinemaRow : View {
    let cinema: Cinema

    var body: some View {
        Text("\(cinema.name)")
    }
}

#if DEBUG
struct CinemaRow_Previews : PreviewProvider {
    static var previews: some View {
        CinemaRow()
    }
}
#endif
