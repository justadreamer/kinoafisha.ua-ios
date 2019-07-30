//
//  ContainerViewController.swift
//  kinoafisha
//
//  Created by eugene on 04.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

@objc class ContainerViewController: UIViewController {
    var content: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let content = content {
            display(content: content)
        }
    }
    
    func display(content: UIViewController) {
        addChild(content)
        content.view.frame = view.bounds
        content.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(content.view)
        content.didMove(toParent: self)
    }
}
