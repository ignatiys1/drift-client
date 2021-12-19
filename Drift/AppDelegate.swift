//
//  AppDelegate.swift
//  Drift
//
//  Created by Ignat Urbanovich on 2.11.21.
//

import UIKit
import Firebase

var THIS_USER = User()


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let idUser = UserDefaults.standard.object(forKey: "user_uid_key") {
            Adapter.shared.getUser(idUser as! Int)
        }
        Adapter.shared.askForCups(false)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
   


}

