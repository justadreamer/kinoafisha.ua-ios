//
//  ImageProvider.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 22/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class ImageHolder: BindableObject {
    var willChange = PassthroughSubject<Void,Never>()
    var url: URL
    
    var errorImage: Image? {
        didSet {
            withAnimation {
                willChange.send()
            }
        }
    }
    
    var image: Image? {
        didSet {
            withAnimation {
                willChange.send()
            }
        }
    }
    
    var imageGroup: some View {
        Group {
            if image != nil {
                image
                .transition(.opacity)
            } else if errorImage != nil {
                errorImage
                .transition(.opacity)
            } else {
                defaultImage
            }
        }
        .frame(width: width, height: height)
    }
    
    var defaultImage = Image(systemName: "hourglass")

    var width: Length
    var height: Length

    init(url: URL, defaultWidth: Length, defaultHeight: Length) {
        self.url = url
        self.width = defaultWidth
        self.height = defaultHeight
        reload()
    }

    private let session = URLSession(configuration: .default)
    private var cancellation: AnyCancellable?

    deinit {
        cancellation?.cancel()
    }

    func reload() {
        if let _ = image {
            return //if image has been loaded no need to reload
        }
        cancellation?.cancel()
        let request = URLRequest.spoofedUA(url: url)
        self.errorImage = nil // we reattempt, so if there was any error, let's clear it
        
        cancellation = session
            .dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> UIImage? in
                //sleep(1) //for debug purposes
                //return nil //for debug purposes
                if let image = UIImage(data: data) {
                    return image
                }
                return nil
            }
            .replaceError(with: nil)
            .map { image in
                if let image = image {
                    //for simplicity a side effect (not on main thread, but it does not hit willChange, so should be ok)
                    self.width = image.size.width
                    self.height = image.size.height

                    return Image(uiImage: image) //comment out for testing failed image load
                }
                
                //for simplicity a side effect again, it hits willChange, so should be on main t. :(
                DispatchQueue.main.async {
                    self.errorImage = Image(systemName: "minus.circle")
                }
                return nil
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
}
