//
//  LoadingState.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 20/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

enum LoadingState<Model> where Model: Decodable, Model: Equatable {
    case initial
    case complete(Model)
    case loading
    case error(Error)
    
    var eraseModel: NoModelLoadingState {
        switch self {
        case .initial: return NoModelLoadingState.complete
        case .complete: return NoModelLoadingState.complete
        case .loading: return NoModelLoadingState.loading
        case .error(let e): return NoModelLoadingState.error(e)
        }
    }
    
    var model: Model? {
        if case let LoadingState.complete(m) = self {
            return m
        }
        return nil
    }
}

enum NoModelLoadingState {
    case complete
    case loading
    case error(Error)
}

extension NoModelLoadingState: Equatable {
    static func == (lhs: NoModelLoadingState, rhs: NoModelLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.complete, .complete): return true
        case (.loading, .loading): return true
        case (.error, .error): return true
        default:
            return false
        }
    }
}
