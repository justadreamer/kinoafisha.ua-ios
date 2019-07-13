//
//  FilmsProvider.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class FilmsProvider: BindableObject {
    var didChange = PassthroughSubject<Void,Never>()

    var films: [Film] = [] {
        didSet {
            didChange.send()
        }
    }

    var isLoading: Bool = false {
        didSet {
            didChange.send()
        }
    }
    
    var url: URL? {
        get {
            loader.url
        }
        set {
            loader.url = newValue
        }
    }

    private var loader: XSLTLoader<[Film]>
    var cancelation: Cancellable?
    
    deinit {
        cancelation?.cancel()
    }
    
    init(url: URL?) {
        self.loader = XSLTLoader(url: url, transformationName: "films", resourceURLProvider: (UIApplication.shared.delegate as! AppDelegate).s3SyncManager)
        reload()
    }
    
    func reload() {
        self.isLoading = true
        
        cancelation =
            self.loader.reload()
            .catch { error -> Just<[Film]> in
                //perform side effect here and return empty cinemas
                print("\(error)")
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] films in
                self?.isLoading = false //for now this is a required side effect which prevents us to use .assign(to:on:)
                self?.films = films
        }
    }
}
