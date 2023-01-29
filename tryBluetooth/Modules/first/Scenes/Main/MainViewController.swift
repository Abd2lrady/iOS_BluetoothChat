//
//  ViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {

    var bleCentralManager: BLECentralManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configCentralManager()
        
    }
    
    func configCentralManager() {
        
        let cbCentralManager = CBCentralManager()
        bleCentralManager = BLECentralManager()
        bleCentralManager?.centralManager = cbCentralManager
        cbCentralManager.delegate = bleCentralManager

        bleCentralManager?.checkPowerStatus { status in
            if status == .poweredOn {
                print("powerOn from view controller")
                self.bleCentralManager?.scan(for: nil) { peripheral in
                    print("hello", peripheral)
                }
            }
        }
    }
}
