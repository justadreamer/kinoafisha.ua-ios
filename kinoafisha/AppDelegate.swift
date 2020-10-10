//
//  AppDelegate.swift
//  
//
//  Created by Eugene Dorfman on 10/10/20.
//

import Foundation
import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MSAppCenter.start("c357110c-bce6-4ba1-1cc7-3faa41591897", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        Flurry.startSession("24FBVSP95KGR8493G4MF")
        return true
    }
}
