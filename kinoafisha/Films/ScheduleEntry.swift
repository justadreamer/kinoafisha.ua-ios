//
//  ScheduleEntry.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import SwiftUI

struct ScheduleEntry: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case title
        case type
        case detailParsedRequest = "detail_parsed_request"
        case showTimes = "show_times"
    }
    
    enum EntryType: String, Codable {
        case film
        case cinema
        case cinemaRoom = "cinema_room"
    }
    
    var title: String
    var type: EntryType
    var detailParsedRequest: ParsedRequest?
    var showTimes: [String]?
}

extension ScheduleEntry: Identifiable {
    var id: String {
        title
    }
}
