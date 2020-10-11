//
//  CinemasContainer.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct CinemasContainer: Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case cityName = "city_name"
        case cinemas
    }

    var cityName: String
    var cinemas: [Cinema]
}


extension CinemasContainer: HasEmptyState {
    var isEmpty: Bool {
        cinemas.isEmpty
    }
}
