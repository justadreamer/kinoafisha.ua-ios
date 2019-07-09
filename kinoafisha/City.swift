//
//  City.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct City: Codable, Equatable, Hashable {
    enum CodingKeys: String, CodingKey {
        case name
        case cinemaURL = "link_cinema"
        case filmURL = "link_kinoafisha"
        case isDefaultSelection = "is_default_selection"
    }

    let name: String
    let cinemaURL: URL
    let filmURL: URL
    let isDefaultSelection: Bool
}
