//
//  ReloadButton.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 20/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct ReloadButton: View {
    var reload: () -> Void
    var body: some View {
        Button(action: {
            self.reload()
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }
}
