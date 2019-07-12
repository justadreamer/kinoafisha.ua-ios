//
//  Cinema.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct Cinema: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case detailURL = "link"
        case thumbnailURL = "thumbnail"
        case address = "address"
        case phone = "phone"
        case rating = "rating"
        case votesCount = "votes_count"
    }

    var name: String
    var detailURL: URL
    var thumbnailURL: URL
    var address: String
    var phone: String
    var rating: String
    var votesCount: String
}
