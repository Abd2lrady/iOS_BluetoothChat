//
//  PeripheralViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit

class PeripheralViewController: UIViewController {

    var blePeripheralManager: BLEPeripheralManager?

    @IBOutlet weak var dataLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Peripheral"
        configPeripheralManager()
    }
    
    func configPeripheralManager() {
        
        blePeripheralManager = BLEPeripheralManager.shared
        
        blePeripheralManager?.checkPowerStatus(checkPowerStatusCompletion: { [weak self] state in
            
            if (state == .poweredOn) {
                print("hello peri")
                
                let service = Service(uuid: Constants.BluetoothUUID.chatServiceUUID,
                                      primary: true,
                                      characteristics: [
                                        Characteristic(uuid: Constants.BluetoothUUID.chatCharactristicsUUID,
                                                       value: nil,
                                                       permissions: [.readable, .writeable],
                                                       properties: [.read, .write, .writeWithoutResponse])])
                
                self?.blePeripheralManager?.addService(service: service)
                self?.blePeripheralManager?.startAdvertising(uuid: Constants.BluetoothUUID.chatServiceUUID,
                                                             localName: "hello peripheral xcode")
            }
        })
        
        blePeripheralManager?.didReceiveWriteRequests = {[weak self] requests in
            if let data = requests?.first?.value {
                self?.dataLabel.text = String(data: data, encoding: .utf8)
            }
        }
        
        blePeripheralManager?.didReceiveReadRequest = { [weak self] request in
            guard let msg = self?.dataLabel.text else { return }
            let data = msg.data(using: .utf8)
            request.value = data
        }
        
    }
}
