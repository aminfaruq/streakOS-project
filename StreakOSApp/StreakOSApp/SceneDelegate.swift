//
//  SceneDelegate.swift
//  StreakOSApp
//
//  Created by Amin faruq on 14/07/26.
//

import UIKit
import SwiftUI
import StreakOSFramework
import StreakOSPresentation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var viewModel: ProgressFeedViewModel!
    private var itemCreator: (any ItemCreator)!
    private var itemUpdater: (any ItemUpdater)!
    private var itemDuplicator: (any ItemDuplicator)!
    
    // Convenience init for tests
    convenience init(
        viewModel: ProgressFeedViewModel,
        itemCreator: any ItemCreator,
        itemUpdater: any ItemUpdater,
        itemDuplicator: any ItemDuplicator
    ) {
        self.init()
        self.viewModel = viewModel
        self.itemCreator = itemCreator
        self.itemUpdater = itemUpdater
        self.itemDuplicator = itemDuplicator
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Bootstrap dependencies if not injected via convenience init
        if viewModel == nil {
            do {
                let deps = try AppComposer.makeDependencies()
                self.viewModel = deps.viewModel
                self.itemCreator = deps.itemCreator
                self.itemUpdater = deps.itemUpdater
                self.itemDuplicator = deps.itemDuplicator
            } catch {
                fatalError("Failed to bootstrap StreakOS App: \(error)")
            }
        }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        configureWindow(window)
        window.makeKeyAndVisible()
    }
    
    private func configureWindow(_ window: UIWindow) {
        let rootSwiftUIView = IOSProgressListView(
            viewModel: viewModel,
            itemCreator: itemCreator,
            itemUpdater: itemUpdater,
            itemDuplicator: itemDuplicator
        )
            .preferredColorScheme(.dark)
        
        let hostingController = UIHostingController(rootView: rootSwiftUIView)
        window.rootViewController = hostingController
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

