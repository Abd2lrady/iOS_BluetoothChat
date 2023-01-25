//
//  AppDelegate.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady on 25/01/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bootApp()
        return true
    }    
}

extension AppDelegate {

    private func bootApp() {
        self.window = UIWindow()
        let rootView = ViewController()
        self.window?.rootViewController = rootView
        self.window?.makeKeyAndVisible()
    }
    
}
