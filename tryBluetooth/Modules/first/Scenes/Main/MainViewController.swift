//
//  ViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(Configuration.current)
        print(Constants.BluetoothUUID.central)
        print(Constants.BluetoothUUID.peripheral)
    }
}
