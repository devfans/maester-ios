//
//  SceneDelegate.swift
//  Maester
//
//  Created by Stefan Liu on 2020/2/3.
//  Copyright © 2020 Stefan Liu. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let state = (UIApplication.shared.delegate as! AppDelegate).state
        if let urlContext = URLContexts.first {
            let url = urlContext.url
            print(url.absoluteString)
            print(url.path)
            print(String(url.path.suffix(from: url.path.index(after: url.path.startIndex))))
            if let raw = Data(base64Encoded: String(url.path.suffix(from: url.path.index(after: url.path.startIndex)))) {
                let data = try? JSONSerialization.jsonObject(with: raw, options: [])
                if let new_page_data = data as? [String: String], url.host == "newlink" {
                    state.new_page_data = new_page_data
                    if let url_str = new_page_data["url"] {
                        state.write_page.content = url_str
                    }
                    if let text = new_page_data["text"] {
                        state.write_page.name = text
                    }
                    state.entry = .AddPage
                    return
                }
            }
        }
        /*
        let data = try! JSONSerialization.jsonObject(with: Data(base64Encoded: host)!, options: [])
        if let new_page_data = data as? [String: String], urlContext.url.path == "/newlink" {
            self.state.entry = .AddPage
            self.state.new_page_data = new_page_data
            if let url = new_page_data["url"] {
                state.write_page.content = url
            }
        }
        */
        
        print("Failed to parse data carried from share extension!")
        state.write_page = Page(withLink: "")
        state.entry = .AddPage
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let state = (UIApplication.shared.delegate as! AppDelegate).state;
        state.book.start { status in
            print("initial sync state: \(status)")
            state.sync_status = status
        }

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = ContentView().environment(\.managedObjectContext, context).environmentObject(state)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window.rootViewController = UIHostingController(rootView: contentView)
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

