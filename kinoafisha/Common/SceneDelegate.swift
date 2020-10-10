//
//  SceneDelegate.swift
//  kinoafisha
//
//  Created by Eugene Dorfman on 9/7/19.
//  Copyright © 2019 justadreamer. All rights reserved.
//

import Foundation
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @State var dummyPresented: Bool = false  //for debug
    var window: UIWindow?
    var providersContainer = ProvidersContainer()

    func jsonFixture(name: String) -> Data {
        let jsonURL = Bundle.main.url(forResource: name, withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        return jsonData
    }

    var fakeFilmsView: some View {
        let jsonData = jsonFixture(name: "films")
        let films = try! JSONDecoder().decode([Film].self, from: jsonData)
        let filmsProvider = ModelProvider<[Film]>(s3SyncManager: providersContainer.s3SyncManager, parsedRequest: nil, transformationName: "", fakeModel: films)
        return FilmsView(filmsProvider: filmsProvider)
            .environmentObject(providersContainer)
    }
    
    var fakeCinemasView: some View {
        let jsonData = jsonFixture(name: "cinemascontainer")
        let cinemasContainer = try! JSONDecoder().decode(CinemasContainer.self, from: jsonData)
        let cinemasProvider = ModelProvider<CinemasContainer>(s3SyncManager: providersContainer.s3SyncManager, parsedRequest: nil, transformationName: "", fakeModel: cinemasContainer)
        return CinemasView(cinemasProvider: cinemasProvider)
            .environmentObject(providersContainer)
    }
    
    var welcomeView: some View {
        WelcomeView(presentOnboarding: providersContainer.selectedCity == nil)
                            .environmentObject(providersContainer)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Use a UIHostingController as window root view controller
        
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            //providersContainer.selectedCity = nil //for debug
                    
            window.rootViewController = UIHostingController(rootView:
                welcomeView
                //fakeFilmsView //for debug
                //fakeCinemasView //for debug
                //SettingsView(isPresented: $dummyPresented).environmentObject(providersContainer) //for debug
            )
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}

