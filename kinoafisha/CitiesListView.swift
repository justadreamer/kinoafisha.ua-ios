//
//  CitiesListView.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CitiesListView : View {
    var cities: [City]

    var body: some View {
        List {
            ForEach(cities.identified(by: \.name)) { city in
                Text("\(city.name)")
            }
        }
    }
}

#if DEBUG
struct CitiesListView_Previews : PreviewProvider {
    static var previews: some View {
        CitiesListView()
    }
}
#endif
