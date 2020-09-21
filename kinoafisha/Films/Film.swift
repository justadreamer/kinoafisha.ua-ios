//
//  Film.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

struct Film: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case thumbnailURL = "thumbnail"
        case rating
        case votesCount = "votes_count"
        case attributes
        case descr = "description"
        case scheduleEntries = "schedule"
        //case detailURL = "detail_url"
        case detailParsedRequest = "detail_parsed_request"
    }
    var title: String
    var subtitle: String?
    var thumbnailURL: URL?
    var detailParsedRequest: ParsedRequest?
    var rating: String
    var votesCount: String
    var attributes: [Attribute]
    var descr: String?
    var scheduleEntries: [ScheduleEntry]?
}
