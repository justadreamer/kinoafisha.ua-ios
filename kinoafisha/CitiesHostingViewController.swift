//
//  CitiesHostViewController.swift
//  kinoafisha
//
//  Created by eugene on 04.07.2019.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CitiesHostingViewController: UIHostingController<CitiesView> {
    convenience init() {
        self.init(rootView: CitiesView())
    }
}


@objc class ObjCCitiesHostingViewController: CitiesHostingViewController {
    
}
