//
//  FilmScheduleView.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 27/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct FilmScheduleView: View {
    var scheduleEntries: [ScheduleEntry]

    var body: some View {
        List(scheduleEntries) { entry in
            if entry.type == .cinema {
                Text("\(entry.title)")
                    .font(.headline)
            } else if entry.type == .cinemaRoom {
                VStack(alignment: .leading) {
                    Text("\(entry.title)")
                        .fontWeight(.semibold)
                    Text("\(entry.showTimes != nil ? entry.showTimes!.joined(separator: " ") : "")")
                        .foregroundColor(.red)
                }
                    .padding(.leading)
            }
        }
    }
}

#if DEBUG
struct FilmScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        FilmScheduleView()
    }
}
#endif
