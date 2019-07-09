//
//  CitiesHostedViewController.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 6/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import UIKit
import SwiftUI

class CitiesHostedViewController: ContainerViewController {
    override func viewDidLoad() {
        let hosting = UIHostingController(rootView: CitiesOnboardingView())
        self.content = hosting
        super.viewDidLoad()
    }
}
