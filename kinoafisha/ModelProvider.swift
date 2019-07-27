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

final class ModelProvider<Model>: BindableObject where Model: Codable, Model: Equatable {
    var willChange = PassthroughSubject<Void, Never>()
    var modelValue = CurrentValueSubject<Model?, Never>(nil)

    var model: Model? {
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

    private var loader: XSLTLoader<Model>?
    var url: URL? {
        get {
            loader?.url
        }
        set {
            loader?.url = newValue
        }
    }
    
    private var cancelations = Set<AnyCancellable>()
    
    deinit {
        cancelAll()
    }
    
    func cancelAll() {
        cancelations.forEach { $0.cancel() }
    }
    
    init(url: URL?, transformationName: String, fakeModel: Model? = nil) {
        if let fakeModel = fakeModel {
            self.model = fakeModel
            self.loadingState = .complete
        } else {
            self.loader = XSLTLoader<Model>(url: url, transformationName: transformationName, resourceURLProvider: (UIApplication.shared.delegate as! AppDelegate).s3SyncManager)

            let subj = self.loader!
                .loadingState
                .receive(on: DispatchQueue.main)
                .share()
                
            subj
                .map { $0.eraseModel }
                .assign(to: \.loadingState, on: self)
                .store(in: &cancelations)
            
            //this caches the previous state of the model, so even if the next response is an error - we
            //have the previous state, which might not be exactly correct and expected, so it is debatable
            subj
                .compactMap { $0.model }
                .assign(to: \.model, on: self)
                .store(in: &cancelations)
            
            subj
                .map { loadingState -> Error? in
                    switch loadingState {
                    case .error(let e): return e
                    default: return nil
                    }
                }
                .compactMap { $0 }
                .sink(receiveValue: { error in
                    print("\(Self.self) error: \(error)")}
                )
                .store(in: &cancelations)
        }
    }
    
    func reload() {
        //if no model yet and we are not loading now
        if self.model == nil && self.loadingState != .loading {
            self.loader?.reload()
        }
    }

    func forceReload() {
        //reload regardless whether we have the model or not
        self.loader?.reload()
    }
}
