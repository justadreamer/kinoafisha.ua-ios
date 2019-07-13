//
//  CinemasProvider.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 10/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class CinemasProvider: BindableObject {
    var didChange = PassthroughSubject<Void, Never>()
    private var loader: XSLTLoader<CinemasContainer>
    var isLoading: Bool = false {
        didSet {
            didChange.send()
        }
    }

    var cinemas: [Cinema] = [] {
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

    var cancelation: Cancellable?

    deinit {
        cancelation?.cancel()
    }

    init(url: URL?) {
        self.loader = XSLTLoader<CinemasContainer>(url: url, transformationName: "cinemas", resourceURLProvider: (UIApplication.shared.delegate as! AppDelegate).s3SyncManager)
        reload()
    }

    func reload() {
        self.isLoading = true

        cancelation =
            self.loader.reload()
                .receive(on: DispatchQueue.main)
                .tryMap { cinemasContainer in
                    cinemasContainer.cinemas
                }
                .catch { error -> Just<[Cinema]> in
                    //perform side effect here and return empty cinemas
                    print("\(error)")
                    return Just([])
                }
                .sink { [weak self] cinemas in
                    self?.isLoading = false //for now this is a required side effect which prevents us to use .assign(to:on:)
                    self?.cinemas = cinemas
                }
    }
}
