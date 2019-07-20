//
//  LoadingView.swift
//  kinoafisha
//
//  Created by eugene on 06.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import SwiftUI

//https://stackoverflow.com/questions/56496638/activity-indicator-in-swiftui

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                    .padding()
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(5)
                    .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
}

