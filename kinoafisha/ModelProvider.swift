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
    var willChange = PassthroughSubject<Void, Never>()
    var modelValue = CurrentValueSubject<Model, Never>(Model.empty)

    var model: Model = Model.empty {
        didSet {
            modelValue.value = model
            willChange.send()
        }
    }

    var isLoading: Bool = false {
        didSet {
            willChange.send()
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
    
    private var cancelations = Set<AnyCancellable>()
    
    deinit {
        cancelAll()
    }
    
    func cancelAll() {
        cancelations.forEach { $0.cancel() }
    }
    
    init(url: URL?, transformationName: String) {
        self.loader = XSLTLoader<Model>(url: url, transformationName: transformationName, resourceURLProvider: (UIApplication.shared.delegate as! AppDelegate).s3SyncManager)
        reload()
    }
    
    func reload() {
        cancelAll()

        self.loader
            .isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancelations)

        let cancellation = self.loader
            .reloadModel
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Model> in
                //perform side effect here and return empty cinemas
                print("\(error)")
                return Just(Model.empty)
            }
            .sink { [weak self] model in
                self?.model = model
                self?.isLoading = false //for now this is a required side effect which prevents us to use .assign(to:on:)
            }
        
        self.cancelations.insert(AnyCancellable(cancellation))
    }

}
