//
//  ModelProvider.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 14/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class ModelProvider<Model>: BindableObject where Model: ProvidesEmptyState, Model: Decodable{
    var didChange = PassthroughSubject<Model, Never>()
    var model: Model = Model.empty {
        didSet {
            didChange.send(model)
        }
    }
    var isLoading: Bool = false {
        didSet {
            didChange.send(model)
        }
    }

    private var loader: XSLTLoader<Model>
    var url: URL? {
        get {
            loader.url
        }
        set {
            loader.url = newValue
        }
    }
    
    private var cancelation: Cancellable?
    deinit {
        cancelation?.cancel()
    }
    
    init(url: URL?, transformationName: String) {
        self.loader = XSLTLoader<Model>(url: url, transformationName: transformationName, resourceURLProvider: (UIApplication.shared.delegate as! AppDelegate).s3SyncManager)
        reload()
    }
    
    func reload() {
        cancelation?.cancel()
        self.isLoading = true
        cancelation =
            self.loader.reloadModel
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Model> in
                //perform side effect here and return empty cinemas
                print("\(error)")
                return Just(Model.empty)
            }
            .sink { [weak self] model in
                self?.isLoading = false //for now this is a required side effect which prevents us to use .assign(to:on:)
                self?.model = model
        }
    }

}
