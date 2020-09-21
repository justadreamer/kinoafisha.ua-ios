//
//  City.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct City: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case name
        case requestCinema = "request_cinema"
        case requestFilm = "request_kinoafisha"
        case isDefaultSelection = "is_default_selection"
    }

    let name: String
    let requestCinema: ParsedRequest
    let requestFilm: ParsedRequest
    let isDefaultSelection: Bool
}

extension City: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}
