//
//  CitiesView.swift
//  kinoafisha
//
//  Created by eugene on 02.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct CitiesView : View {
    @ObjectBinding var citiesViewModel = CitiesLoader()
    var body: some View {
        LoadingView(isShowing: $citiesViewModel.isLoading) {
            CitiesListView(cities: self.citiesViewModel.cities)
        }
    }
}

#if DEBUG
struct CitiesView_Previews : PreviewProvider {
    static var previews: some View {
        CitiesView()
    }
}
#endif
