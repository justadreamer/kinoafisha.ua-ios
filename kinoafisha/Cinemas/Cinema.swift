//
//  Cinema.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct Cinema: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case name
        case detailParsedRequest = "detail_parsed_request"
        case thumbnailURL = "thumbnail"
        case address = "address"
        case phone = "phone"
        case rating = "rating"
        case votesCount = "votes_count"
    }

    var name: String
    var detailParsedRequest: ParsedRequest
    var thumbnailURL: URL
    var address: String
    var phone: String
    var rating: String
    var votesCount: String
}
