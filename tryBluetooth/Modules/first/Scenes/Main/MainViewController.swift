//
//  ViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    
    var bleCentralManager: BLECentralManager?
    var blePeripheralManager: BLEPeripheralManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Peripheral"
        configPeripheralManager()
    }
    
    func configCentralManager() {
        
        bleCentralManager = BLECentralManager.shared

        bleCentralManager?.checkPowerStatus { status in
            if status == .poweredOn {
                print("powerOn from view controller")
                self.bleCentralManager?.scan(for: nil) { peripheral in
                    print("hello", peripheral)
                }
            }
        }
    }
    
    func configPeripheralManager() {
        
        blePeripheralManager = BLEPeripheralManager.shared
        
        blePeripheralManager?.checkPowerStatus(checkPowerStatusCompletion: { state in
            if (state == .poweredOn) {
                print("hello peri")
                let service = Service(uuid: "796869ed-af4f-4577-a6cd-8c6d259f9cca",
                                      primary: true,
                                      characteristics: [Characteristic(uuid: "56ac37c0-a075-11ed-a8fc-0242ac120002",
                                                                       value: nil,
                                                                       permissions: [.readable, .writeable],
                                                                       properties: [.read, .write])])
                self.blePeripheralManager?.addService(service: service)
                self.blePeripheralManager?.startAdvertising(uuid: "796869ed-af4f-4577-a6cd-8c6d259f9cca",
                                                            localName: "hello peripheral xcode")
            }
        })
        
        blePeripheralManager?.didReceiveWriteRequests = { requests in
            if let data = requests?.first?.value {
                self.dataLabel.text = String(data: data, encoding: .utf8)
            }
        }
        
    }
}
