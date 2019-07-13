//
//  ProvidesEmptyState.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 13/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation

protocol ProvidesEmptyState {
    static var empty: Self { get }
}

extension Array: ProvidesEmptyState  {
    static var empty: Self {
        return Array()
    }
}
