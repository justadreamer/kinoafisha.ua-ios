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

final class ModelProvider<Model>: ObservableObject where Model: Codable, Model: Equatable {
    var objectWillChange = PassthroughSubject<Void, Never>()
    var modelValue = CurrentValueSubject<Model?, Never>(nil)
    var s3SyncManager: SkyS3SyncManager
    
    var model: Model? {
        didSet {
            modelValue.value = model
            objectWillChange.send()
        }
    }

    var loadingState: NoModelLoadingState = .complete {
        didSet {
            objectWillChange.send()
        }
    }

    private var loader: XSLTLoader<Model>?
    var parsedRequest: ParsedRequest? {
        get {
            loader?.parsedRequest
        }
        set {
            loader?.parsedRequest = newValue
        }
    }
    
    private var cancelations = Set<AnyCancellable>()
    
    deinit {
        cancelAll()
    }
    
    func cancelAll() {
        cancelations.forEach { $0.cancel() }
    }
    
    init(s3SyncManager: SkyS3SyncManager, parsedRequest: ParsedRequest?, transformationName: String, fakeModel: Model? = nil) {
        self.s3SyncManager = s3SyncManager
        if let fakeModel = fakeModel {
            self.model = fakeModel
        } else {
            self.loader = XSLTLoader<Model>(parsedRequest: parsedRequest, transformationName: transformationName, resourceURLProvider: s3SyncManager)
            createSubscriptions()
        }
    }
    
    func createSubscriptions() {
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
            .compactMap {
                return $0.model
            }
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
    
    //erase model object, so when reload() is called it reloads data
    func invalidate() {
        self.model = nil
    }
}
