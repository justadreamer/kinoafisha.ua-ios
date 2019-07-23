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
    var image: Image? {
        didSet {
            withAnimation {
                willChange.send()
            }
        }
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
        cancellation?.cancel()
        let request = URLRequest.spoofedUA(url: url)
        cancellation = session
            .dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> UIImage? in
                if let image = UIImage(data: data) {
                    return image
                }
                return nil
            }
            .replaceError(with: nil)
            .map { image in
                if let image = image {
                    //sleep(1) //for debug to see hourglass longer

                    //a bit imperative, but simple setting new width/height
                    self.width = image.size.width
                    self.height = image.size.height

                    return Image(uiImage: image) //comment out for testing failed image load
                }
                return Image(systemName: "minus.circle")
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
}
