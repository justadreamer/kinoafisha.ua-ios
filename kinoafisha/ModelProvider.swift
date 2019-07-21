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

final class ModelProvider<Model>: BindableObject where Model: ProvidesEmptyState, Model: Decodable, Model: Equatable {
    var willChange = PassthroughSubject<Void, Never>()
    var modelValue = CurrentValueSubject<Model, Never>(Model.empty)

    var model: Model = Model.empty {
        didSet {
            modelValue.value = model
            willChange.send()
        }
    }

    var loadingState: NoModelLoadingState = .complete {
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

        let subj = self.loader
            .loadingState
            .receive(on: DispatchQueue.main)
            .share()
            
        subj
            .map { $0.eraseModel }
            .assign(to: \.loadingState, on: self)
            .store(in: &cancelations)
        
        //this caches the previous state of the model, so even if the next response is an error - we
        //have the previous state, which might not be exactly correct and expected
        subj
            .compactMap { $0.model }
            .assign(to: \.model, on: self)
            .store(in: &cancelations)
    }
    
    func reload() {
        self.loader.reload()
    }

}
