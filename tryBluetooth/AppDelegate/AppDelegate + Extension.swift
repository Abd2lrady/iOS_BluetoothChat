//
//  AppDelegate + Extension.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit

extension AppDelegate {

    func bootApp() {
        self.window = UIWindow()
//        let rootView = MainViewController()
        let rootView = CentralViewController()
//        let rootView = PeripheralViewController()

        self.window?.rootViewController = rootView
        self.window?.makeKeyAndVisible()
    }
}
