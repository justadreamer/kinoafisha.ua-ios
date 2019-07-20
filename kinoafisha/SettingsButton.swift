//
//  SettingsButton.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 20/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

struct SettingsButton: View {
    @Binding var presentSettings: Bool
    
    var body: some View {
        Button(action: {
            self.presentSettings = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}
