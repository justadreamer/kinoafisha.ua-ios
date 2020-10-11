//
//  HasEmptyState.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/10/20.
//  Copyright © 2020 justadreamer. All rights reserved.
//

import Foundation

protocol HasEmptyState {
    var isEmpty: Bool { get }
}

extension Array: HasEmptyState {
    
}
