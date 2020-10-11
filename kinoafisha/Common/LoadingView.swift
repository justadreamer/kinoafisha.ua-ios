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
    @Binding var state: NoModelLoadingState
    @Binding var isEmpty: Bool

    var isLoading: Bool {
        state == NoModelLoadingState.loading
    }
    
    var isError: Bool {
        error != nil
    }
    
    var error: String? {
        if case let NoModelLoadingState.error(e) = state {
            return e.localizedDescription
        }
        return nil
    }

    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isLoading)
                    .blur(radius: self.isLoading ? 3 : 0)
                
                VStack {
                    Text("Загрузка...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                    .padding()
                    .frame(width: geometry.size.width/3, height: geometry.size.height/5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(5)
                    .opacity(self.isLoading ? 1 : 0)
                
                VStack {
                    Text("Ошибка")
                    Text("\(self.isError ? self.error! : "")")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(5)
                    .opacity(self.isError ? 1 : 0)
                
                VStack {
                    Text("Нет контента")
                    Text("\(self.isError ? self.error! : "")")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(5)
                .opacity(self.isEmpty ? 1 : 0)
            }
        }
    }
}
