//
//  LoadingState.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 20/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

enum LoadingState<Model>: Equatable where Model: Decodable, Model: Equatable {
    case initial
    case complete(Model)
    case loading
    case error(String)
    
    var eraseModel: NoModelLoadingState {
        switch self {
        case .initial: return NoModelLoadingState.complete
        case .complete: return NoModelLoadingState.complete
        case .loading: return NoModelLoadingState.loading
        case .error(let s): return NoModelLoadingState.error(s)
        }
    }
    
    var model: Model? {
        if case let LoadingState.complete(m) = self {
            return m
        }
        return nil
    }
}

enum NoModelLoadingState: Equatable {
    case complete
    case loading
    case error(String)
}
