//
//  ScheduleEntry.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation


struct ScheduleEntry: Codable, Equatable {

    enum EntryType: String, Codable {
        case film
        case cinema
        case cinemaRoom = "cinema_room"
    }
    
    var title: String
    var type: EntryType
    var url: URL
    var showTimes: [String]
}
