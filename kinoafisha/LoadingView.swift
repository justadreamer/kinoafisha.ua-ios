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
                    Text("Загрузка...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                    .padding()
                    .frame(width: geometry.size.width / 3,
                       height: geometry.size.height / 3)
                    
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(5)
                    .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
